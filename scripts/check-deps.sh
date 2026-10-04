#!/usr/bin/env bash
# Checks that your operating system is supported and that every tool this
# repository needs is installed - see REQUIREMENTS.md, especially section 1
# (supported operating systems) and section 3 (required software), which
# this script's checks and version numbers are kept in sync with. Versions
# are compared with the pins in mise.toml.
#
# Run it with `make check` (see the Makefile) or directly:
#   bash scripts/check-deps.sh
#
# Written for bash 3.2 (macOS's default /bin/bash) as well as newer bash -
# no associative arrays, no `${var,,}`, no `sort -V` (a GNU-only flag the
# default BSD `sort` on macOS does not have) - see ver_ge() below instead.

set -u

FAIL_COUNT=0
WARN_COUNT=0

# --- output helpers ----------------------------------------------------

if [ -t 1 ]; then
  C_OK="\033[32m"
  C_WARN="\033[33m"
  C_FAIL="\033[31m"
  C_RESET="\033[0m"
else
  C_OK=""
  C_WARN=""
  C_FAIL=""
  C_RESET=""
fi

section() {
  echo ""
  echo "== $1 =="
}

ok() {
  printf "  ${C_OK}[ OK ]${C_RESET} %s\n" "$1"
}

warn() {
  printf "  ${C_WARN}[WARN]${C_RESET} %s\n" "$1"
  WARN_COUNT=$((WARN_COUNT + 1))
}

fail() {
  printf "  ${C_FAIL}[FAIL]${C_RESET} %s\n" "$1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

# ver_ge HAVE WANT - true (exit 0) if version HAVE >= WANT, comparing
# dot-separated numeric fields (so "3.9" < "3.10", unlike a plain string
# compare). Implemented in plain awk instead of `sort -V` because macOS's
# default BSD `sort` doesn't support `-V` (a GNU coreutils extension) - see
# the file header.
ver_ge() {
  awk -v have="$1" -v want="$2" '
    BEGIN {
      n1 = split(have, h, ".")
      n2 = split(want, w, ".")
      max = (n1 > n2 ? n1 : n2)
      for (i = 1; i <= max; i++) {
        hv = (i <= n1) ? h[i] + 0 : 0
        wv = (i <= n2) ? w[i] + 0 : 0
        if (hv > wv) { exit 0 }
        if (hv < wv) { exit 1 }
      }
      exit 0
    }'
}

# first_version TEXT - extracts the first "N.N" or "N.N.N" substring found
# in TEXT (most --version outputs have exactly one, but some, like
# `aws --version`, have several - this picks the first, which is always the
# tool's own version in every command this script checks).
first_version() {
  echo "$1" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1
}

REQUIREMENTS_HINT="Run 'mise install' in the repository root, or see REQUIREMENTS.md section 3 (Required software) for your OS."

# --- operating system ----------------------------------------------------

check_os() {
  section "Operating system (REQUIREMENTS.md section 1)"

  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
    Linux)
      distro="unknown"
      distro_ver="unknown"
      if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091  # a real, standard system file - not part of this repo
        distro="$(. /etc/os-release && echo "$ID")"
        # shellcheck disable=SC1091
        distro_ver="$(. /etc/os-release && echo "$VERSION_ID")"
      fi
      if [ "$distro" != "ubuntu" ]; then
        warn "Detected Linux distro '$distro' ($arch) - this repository is tested on Ubuntu 22.04/24.04/26.04 (amd64). Other distros may still work; see REQUIREMENTS.md section 1."
      elif [ "$arch" != "x86_64" ]; then
        warn "Detected Ubuntu $distro_ver on '$arch' - this repository is tested on amd64 (x86_64); see REQUIREMENTS.md section 1."
      else
        case "$distro_ver" in
          22.04 | 24.04 | 26.04)
            ok "Ubuntu $distro_ver ($arch) - supported"
            ;;
          *)
            warn "Ubuntu $distro_ver ($arch) detected - this repository is tested on 22.04/24.04/26.04; $distro_ver is likely fine too, but see REQUIREMENTS.md section 1."
            ;;
        esac
      fi
      ;;
    Darwin)
      macos_ver="$(sw_vers -productVersion 2>/dev/null || echo "")"
      if [ "$arch" != "arm64" ] && [ "$arch" != "x86_64" ]; then
        warn "macOS on unexpected architecture '$arch' - see REQUIREMENTS.md section 1."
      elif [ -z "$macos_ver" ]; then
        warn "macOS ($arch) detected, but the version could not be determined."
      elif ver_ge "$macos_ver" "13.0"; then
        ok "macOS $macos_ver ($arch) - supported"
      else
        warn "macOS $macos_ver ($arch) detected - this repository targets macOS 13+; see REQUIREMENTS.md section 1."
      fi
      ;;
    *)
      fail "Operating system '$os' is not directly supported. Windows users: install WSL2 with an Ubuntu distro and re-run this check inside it - see REQUIREMENTS.md section 1."
      ;;
  esac
}

# --- tools ------------------------------------------------------------------

# check_tool NAME LEVEL MIN_VERSION WHY VERSION_COMMAND...
# LEVEL is "required" (missing = FAIL) or "optional" (missing = WARN).
# MIN_VERSION "" skips the version comparison.
check_tool() {
  name="$1"; level="$2"; min="$3"; why="$4"; shift 4
  if ! command -v "$name" >/dev/null 2>&1; then
    if [ "$level" = "required" ]; then
      fail "$name not found ($why). $REQUIREMENTS_HINT"
    else
      warn "$name not found (optional - $why)."
    fi
    return
  fi
  have="$(first_version "$("$@" 2>&1)")"
  if [ -z "$min" ]; then
    ok "$name${have:+ $have} found"
  elif [ -z "$have" ]; then
    warn "$name found, but its version could not be parsed."
  elif ver_ge "$have" "$min"; then
    ok "$name $have (>= $min)"
  else
    warn "$name $have found, but this repository is tested with $min - run 'mise install' (REQUIREMENTS.md section 3)."
  fi
}

check_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    fail "docker not found (runs floci and floci-gcp). $REQUIREMENTS_HINT"
    return
  fi
  have="$(first_version "$(docker --version 2>&1)")"
  if ! docker info >/dev/null 2>&1; then
    fail "docker was found${have:+ (version $have)}, but its daemon isn't reachable. Start Docker Desktop, or 'colima start' - see REQUIREMENTS.md section 3.2."
    return
  fi
  ok "Docker${have:+ $have} (daemon reachable)"
  if compose_output="$(docker compose version 2>&1)"; then
    have="$(first_version "$compose_output")"
    if [ -n "$have" ] && ver_ge "$have" "2.20"; then
      ok "Docker Compose $have (>= 2.20)"
    else
      warn "Docker Compose${have:+ $have} found; this repository is tested with 2.20+."
    fi
  else
    fail "'docker compose' (v2) is not available. $REQUIREMENTS_HINT"
  fi
}

check_floci_dns() {
  # floci's documented wildcard domain must resolve to this machine
  # (REQUIREMENTS.md section 5.3); some DNS filters block it.
  if command -v getent >/dev/null 2>&1; then
    resolved="$(getent hosts localhost.floci.io 2>/dev/null)"
  elif command -v dscacheutil >/dev/null 2>&1; then
    resolved="$(dscacheutil -q host -a name localhost.floci.io 2>/dev/null | grep address)"
  else
    resolved="unknown"
  fi
  if [ -n "$resolved" ]; then
    ok "localhost.floci.io resolves (S3 virtual-hosted requests to floci work)"
  else
    warn "localhost.floci.io does not resolve - see REQUIREMENTS.md section 5.3 (add '127.0.0.1 localhost.floci.io' to /etc/hosts)."
  fi
}

# --- main ----------------------------------------------------

check_os

section "Recommended: the tool manager (REQUIREMENTS.md section 3.3)"
check_tool mise optional "" "installs every pinned tool below with 'mise install'" mise --version

section "Required software (REQUIREMENTS.md section 3)"
check_tool terraform required 1.16.5 "Terraform CLI" terraform version
check_tool tofu required 1.13.1 "OpenTofu CLI" tofu version
check_tool terragrunt required 1.1.6 "Terragrunt CLI" terragrunt --version
check_tool tflint required 0.64.0 "make lint" tflint --version
check_tool trivy required 0.75.0 "make security" trivy --version
check_tool terraform-docs required 0.24.0 "make docs" terraform-docs --version
check_tool python3 required 3.14 "scripts and Python tests" python3 --version
check_tool uv required "" "Python dependencies (uv sync)" uv --version
check_tool aws required 2.0 "AWS CLI, in the README commands" aws --version
check_tool jq required 1.6 "parses JSON in the README commands" jq --version
check_tool git required "" "version control" git --version
check_tool curl required "" "calls the emulators' REST APIs" curl --version
check_tool make required "" "the Makefile shortcuts" make --version
check_docker
check_floci_dns

section "Optional software"
check_tool pre-commit optional 4.6.2 "git hooks: pre-commit install" pre-commit --version
check_tool shellcheck optional 0.11.0 "checks this script" shellcheck --version
check_tool gcloud optional "" "gcloud commands against floci-gcp and real GCP" gcloud --version

echo ""
echo "======================================================================"
if [ "$FAIL_COUNT" -gt 0 ]; then
  printf "${C_FAIL}%s missing/unsupported required item(s), %s warning(s).${C_RESET}\n" "$FAIL_COUNT" "$WARN_COUNT"
  echo ""
  echo "Run 'mise install' in the repository root, then see REQUIREMENTS.md:"
  echo "  - Ubuntu: section 3.1"
  echo "  - macOS:  section 3.2"
  echo "======================================================================"
  exit 1
else
  printf "${C_OK}All required software found and your operating system is supported${C_RESET} (%s warning(s)).\n" "$WARN_COUNT"
  echo "======================================================================"
  exit 0
fi
