# Makefile for learning-terraform.
#
# Every target is a SHORTCUT for commands that the documentation teaches step
# by step (docs/, labs/*/README.md, REQUIREMENTS.md). Learn the long form
# first - `terraform init`, `terragrunt run --all -- plan`... - then use these
# to run many directories at once. `make` (or `make help`) lists every target.
#
# Tools come from mise.toml: when mise is installed, every command runs
# through `mise exec`, so the pinned versions are used even if your shell
# has not activated mise. Python packages come from uv (pyproject.toml).

SHELL := /bin/bash
.DEFAULT_GOAL := help

# --- knobs (override on the command line: make test TF=terraform) ----------
# Binary used by the module/lab tests and by Terragrunt: tofu | terraform.
TF ?= tofu
# Terragrunt scope: CLOUD = aws | gcp, ENV = dev | stg. Empty = everything.
CLOUD ?=
ENV ?=
# Name prefix for list-resources (lt-<env>-...).
PREFIX ?= lt-$(if $(ENV),$(ENV),)
# Variables loaded before commands that talk to the emulators: your .env if
# it exists, otherwise .env.example (which points at the emulators).
ENV_FILE ?= $(if $(wildcard .env),.env,.env.example)

RUN := $(if $(shell command -v mise 2>/dev/null),mise exec --,)
LOAD_ENV := set -a; source $(abspath $(ENV_FILE)); set +a;
# Terragrunt gets ONLY the emulator URLs from the env file: live/root.hcl
# sets the other variables per account, and a full .env (AWS_ENDPOINT_URL...)
# must never reach the state bootstrap of a real account.
TG_ENV = FLOCI_AWS_ENDPOINT="$$(set -a; source $(abspath $(ENV_FILE)); echo "$$FLOCI_AWS_ENDPOINT")" \
	FLOCI_GCP_ENDPOINT="$$(set -a; source $(abspath $(ENV_FILE)); echo "$$FLOCI_GCP_ENDPOINT")"
COMPOSE := docker compose

# Directories with Terraform/OpenTofu code (not the legacy 0.11 examples).
MODULE_DIRS := $(patsubst %/,%,$(wildcard modules/*/))
WRAPPER_DIRS := $(patsubst %/,%,$(wildcard modules/*/wrappers/))
EXAMPLE_DIRS := $(patsubst %/,%,$(wildcard modules/*/examples/*/))
LAB_DIRS := $(patsubst %/,%,$(wildcard labs/*/))
TF_DIRS := $(MODULE_DIRS) $(WRAPPER_DIRS) $(EXAMPLE_DIRS) $(LAB_DIRS)
DOC_DIRS := $(MODULE_DIRS) $(WRAPPER_DIRS) $(EXAMPLE_DIRS)

# Terragrunt working directory for CLOUD/ENV (live/<cloud>/<account>/<env>).
TG_DIRS := $(if $(CLOUD)$(ENV),$(patsubst %/,%,$(wildcard live/$(if $(CLOUD),$(CLOUD),*)/*/$(if $(ENV),$(ENV),*)/)),live)

# tf_in_dir DIR, COMMANDS: runs COMMANDS in DIR with a throw-away
# TF_DATA_DIR, so no .terraform/ is left inside modules/ (Terragrunt would
# copy it along with the module source).
define tf_in_dir
	@set -e; data_dir="$$(mktemp -d)"; trap 'rm -rf "$$data_dir"' EXIT; \
	cd $(1) && export TF_DATA_DIR="$$data_dir" && \
	$(RUN) $(TF) init -backend=false -input=false -no-color > "$$data_dir/init.log" 2>&1 || { cat "$$data_dir/init.log"; exit 1; }; \
	$(2); \
	case "$(1)" in modules/*) rm -f .terraform.lock.hcl;; esac
endef

.PHONY: help check install \
	floci-start floci-stop floci-status floci-bootstrap floci-destroy \
	fmt fmt-check validate lint security docs docs-check \
	test test-unit test-integration test-python test-smoke test-all _tg_cache \
	tg-list tg-graph tg-plan tg-apply tg-destroy tg-output tg-drift \
	list-resources clean

help: ## Show this list of targets
	@echo "Targets:"
	@grep -E '^[a-zA-Z0-9_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-17s %s\n", $$1, $$2}'
	@echo ""
	@echo "Knobs: TF=tofu|terraform  CLOUD=aws|gcp  ENV=dev|stg  PREFIX=lt-dev"
	@echo "Examples:"
	@echo "  make install floci-start floci-bootstrap"
	@echo "  make test TF=terraform          make test-integration"
	@echo "  make tg-plan CLOUD=aws ENV=dev  make tg-apply ENV=dev"
	@echo "  make list-resources PREFIX=lt-dev"

# --- setup ---------------------------------------------------------------------

check: ## Check your OS and every tool (REQUIREMENTS.md section 3)
	@$(RUN) bash scripts/check-deps.sh

install: ## Install the pinned tools (mise), the Python packages (uv) and the tflint plugins
	mise install
	$(RUN) uv sync
	$(RUN) tflint --init --config $(CURDIR)/.tflint.hcl

# --- emulators (floci = AWS, floci-gcp = GCP) -----------------------------------

floci-start: ## Start floci and floci-gcp and wait until they answer
	@$(LOAD_ENV) $(COMPOSE) up -d
	@$(LOAD_ENV) echo -n "Waiting for the emulators"; \
	for i in $$(seq 1 60); do \
		if curl -s -o /dev/null "http://localhost:$${FLOCI_AWS_PORT:-4566}" && \
		   curl -s -o /dev/null "http://localhost:$${FLOCI_GCP_PORT:-4588}/storage/v1/b?project=floci-local"; then \
			echo " - ready."; exit 0; fi; \
		echo -n "."; sleep 2; \
	done; echo ""; echo "The emulators did not answer in 120s - see: docker compose logs" >&2; exit 1

floci-stop: ## Stop the emulators, keeping their data (./.floci)
	$(COMPOSE) stop

floci-status: ## Show the emulators' state and URLs
	@$(COMPOSE) ps
	@$(LOAD_ENV) echo ""; \
	echo "floci (AWS):     $$AWS_ENDPOINT_URL   console: http://localhost:$${FLOCI_AWS_PORT:-4566}/_floci/ui"; \
	echo "floci-gcp (GCP): $$FLOCI_GCP_ENDPOINT"

# The state buckets of the accounts/projects with target = "floci", created
# with the emulators' APIs. (On a real account, `terragrunt ... --backend-bootstrap`
# creates them - see docs/06-terragrunt.md. On floci-gcp it must not be used:
# Terragrunt's own GCS client talks to the real Google Cloud.)
floci-bootstrap: ## Create the S3 and GCS state buckets Terragrunt uses on the emulators
	@$(LOAD_ENV) for f in live/aws/*/account.hcl; do \
		grep -q 'target *= *"floci"' "$$f" || continue; \
		account="$$(sed -n 's/^ *account_id *= *"\(.*\)".*/\1/p' "$$f")"; \
		region="$$(sed -n 's/^ *state_region *= *"\(.*\)".*/\1/p' "$$f")"; \
		bucket="lt-tfstate-$$account"; \
		if $(RUN) aws s3api head-bucket --bucket "$$bucket" >/dev/null 2>&1; then \
			echo "s3://$$bucket already exists"; \
		else \
			$(RUN) aws s3api create-bucket --bucket "$$bucket" --region "$$region" >/dev/null && \
			$(RUN) aws s3api put-bucket-versioning --bucket "$$bucket" --versioning-configuration Status=Enabled && \
			echo "created s3://$$bucket on floci"; \
		fi; \
	done
	@$(LOAD_ENV) for f in live/gcp/*/account.hcl; do \
		grep -q 'target *= *"floci"' "$$f" || continue; \
		project="$$(sed -n 's/^ *project_id *= *"\(.*\)".*/\1/p' "$$f")"; \
		bucket="lt-tfstate-$$project"; \
		if curl -sf -o /dev/null "$$FLOCI_GCP_ENDPOINT/storage/v1/b/$$bucket"; then \
			echo "gs://$$bucket already exists"; \
		else \
			curl -sf -X POST -H 'Content-Type: application/json' \
				"$$FLOCI_GCP_ENDPOINT/storage/v1/b?project=$$project" \
				-d "{\"name\":\"$$bucket\",\"versioning\":{\"enabled\":true}}" > /dev/null && \
			echo "created gs://$$bucket on floci-gcp"; \
		fi; \
	done

# ./.floci is written by the containers (as root), so it is deleted from a
# throw-away floci container instead of with a plain `rm`. Containers that
# the emulators started (ECS tasks, RDS, Cloud Run) are only LISTED: other
# projects using floci create containers with the same labels.
floci-destroy: ## Remove the emulators and ALL their local data (asks first; CONFIRM=yes skips)
	@if [ "$(CONFIRM)" != "yes" ]; then \
		read -r -p "Delete the emulators and every resource stored in ./.floci? Type 'yes': " answer; \
		[ "$$answer" = "yes" ] || { echo "Cancelled."; exit 1; }; \
	fi
	$(COMPOSE) down --remove-orphans
	@if [ -d .floci ]; then \
		docker run --rm --entrypoint bash -v "$(CURDIR):/repo" floci/floci:2.1.0 -c 'rm -rf /repo/.floci' && \
		echo "Deleted ./.floci"; \
	fi
	@left="$$(docker ps -a --filter label=floci=true --format '{{.Names}}')"; \
	if [ -n "$$left" ]; then \
		echo "Containers labelled floci=true still exist (they may belong to another project):"; \
		echo "$$left" | sed 's/^/  /'; \
		echo "Remove the ones from this project with: docker rm -f <name>"; \
	fi

# --- static checks -----------------------------------------------------------------

fmt: ## Format every .tf/.tftest.hcl file and the Terragrunt .hcl files
	$(RUN) $(TF) fmt -recursive modules
	$(RUN) $(TF) fmt -recursive labs
	$(RUN) terragrunt hcl fmt --working-dir live

fmt-check: ## Fail if any file is not formatted (CI-friendly)
	$(RUN) $(TF) fmt -recursive -check -diff modules
	$(RUN) $(TF) fmt -recursive -check -diff labs
	$(RUN) terragrunt hcl fmt --check --working-dir live

validate: ## terraform/tofu validate in every module, wrapper, example and lab
	@for d in $(TF_DIRS); do echo "== validate $$d ($(TF))"; \
		$(MAKE) --no-print-directory _validate DIR=$$d || exit 1; done

_validate:
	$(call tf_in_dir,$(DIR),$(RUN) $(TF) validate -no-color)

lint: ## tflint in every module, wrapper, example and lab (make install runs tflint --init)
	@for d in $(TF_DIRS); do echo "== tflint $$d"; \
		$(RUN) tflint --chdir $$d --config $(CURDIR)/.tflint.hcl --format compact || exit 1; done

security: ## trivy misconfiguration scan of modules/ (fails on HIGH/CRITICAL)
	$(RUN) trivy config --quiet --severity HIGH,CRITICAL --exit-code 1 modules

docs: ## Regenerate the terraform-docs part of every module/wrapper/example README
	@for d in $(DOC_DIRS); do $(RUN) terraform-docs --config $(CURDIR)/.terraform-docs.yml $$d; done

docs-check: ## Fail if any README's generated part is out of date
	@for d in $(DOC_DIRS); do $(RUN) terraform-docs --config $(CURDIR)/.terraform-docs.yml --output-check $$d || exit 1; done

# --- tests --------------------------------------------------------------------------

test-unit: ## Unit tests (mock providers, no cloud) of modules, wrappers and labs
	@for d in $(MODULE_DIRS) $(WRAPPER_DIRS) $(LAB_DIRS); do \
		for f in tests/unit.tftest.hcl tests/main.tftest.hcl; do \
			[ -f $$d/$$f ] || continue; \
			echo "== $(TF) test $$d/$$f"; \
			$(MAKE) --no-print-directory _test DIR=$$d FILTER=$$f || exit 1; \
		done; done

test-integration: ## Integration tests on the emulators (make floci-start first)
	@for d in $(MODULE_DIRS) $(LAB_DIRS); do \
		[ -f $$d/tests/integration.tftest.hcl ] || continue; \
		echo "== $(TF) test $$d/tests/integration.tftest.hcl"; \
		$(MAKE) --no-print-directory _test DIR=$$d FILTER=tests/integration.tftest.hcl WITH_ENV=1 || exit 1; done

_test:
	$(call tf_in_dir,$(DIR),$(if $(WITH_ENV),$(LOAD_ENV)) $(RUN) $(TF) test -filter=$(FILTER) -no-color)

test-python: ## Lint, type-check and unit-test the Python scripts (coverage >= 80%)
	$(RUN) uv run ruff check scripts tests
	$(RUN) uv run ruff format --check scripts tests
	$(RUN) uv run mypy scripts tests
	$(RUN) uv run pytest --cov --cov-report=term-missing

test-smoke: ## Check the deployed dev stacks answer (after make tg-apply ENV=dev)
	@$(LOAD_ENV) $(RUN) uv run pytest -m smoke -v tests/smoke

test: fmt-check validate lint security docs-check test-unit test-python ## Every check that needs no emulator

test-all: ## make test with tofu AND terraform, plus the integration tests
	$(MAKE) test TF=tofu
	$(MAKE) test TF=terraform
	$(MAKE) test-integration TF=tofu

# --- Terragrunt (live/) ------------------------------------------------------------

# A .terragrunt-cache initialised by one binary fails with the other
# ("Backend configuration changed"), so the caches under live/ are deleted
# whenever TF differs from the previous run (recorded in .terragrunt-tf).
_tg_cache:
	@if [ "$$(cat .terragrunt-tf 2>/dev/null)" != "$(TF)" ]; then \
		find live -name .terragrunt-cache -type d -prune -exec rm -rf {} +; \
		echo "$(TF)" > .terragrunt-tf; \
		echo "TF changed to $(TF): deleted the Terragrunt caches under live/"; \
	fi

tg-list: ## List the Terragrunt units in scope (CLOUD/ENV)
	@for d in $(TG_DIRS); do $(RUN) terragrunt list --working-dir $$d; done

tg-graph: ## Show the units' dependency graph (DOT format)
	@for d in $(TG_DIRS); do $(RUN) terragrunt dag graph --working-dir $$d; done

tg-plan: _tg_cache ## terragrunt run --all -- plan, in dependency order
	@for d in $(TG_DIRS); do $(TG_ENV) $(RUN) terragrunt run --all --non-interactive --working-dir $$d --tf-path $(TF) -- plan || exit 1; done

tg-apply: _tg_cache ## terragrunt run --all -- apply, in dependency order (make floci-bootstrap first)
	@for d in $(TG_DIRS); do $(TG_ENV) $(RUN) terragrunt run --all --non-interactive --working-dir $$d --tf-path $(TF) -- apply || exit 1; done

tg-destroy: _tg_cache ## terragrunt run --all -- destroy, in reverse dependency order
	@for d in $(TG_DIRS); do $(TG_ENV) $(RUN) terragrunt run --all --non-interactive --working-dir $$d --tf-path $(TF) -- destroy || exit 1; done

tg-output: _tg_cache ## Show the outputs of every unit in scope
	@for d in $(TG_DIRS); do $(TG_ENV) $(RUN) terragrunt run --all --non-interactive --working-dir $$d --tf-path $(TF) -- output || exit 1; done

tg-drift: _tg_cache ## Fail when the real resources differ from the code (plan -detailed-exitcode)
	@for d in $(TG_DIRS); do $(TG_ENV) $(RUN) terragrunt run --all --non-interactive --working-dir $$d --tf-path $(TF) -- plan -detailed-exitcode || exit 1; done

# --- inspection and cleanup -----------------------------------------------------------

list-resources: ## List the resources whose name starts with PREFIX (CLOUD=aws|gcp, default both)
	@$(LOAD_ENV) $(RUN) uv run python scripts/list_resources.py $(if $(CLOUD),$(CLOUD),all) --prefix $(PREFIX)

clean: ## Delete caches (.terragrunt-cache, .terraform, Python caches); keeps the emulators' data
	find live labs modules -name .terragrunt-cache -type d -prune -exec rm -rf {} +
	rm -f .terragrunt-tf
	find labs modules -name .terraform -type d -prune -exec rm -rf {} +
	find modules -name .terraform.lock.hcl -delete
	rm -rf .pytest_cache .mypy_cache .ruff_cache htmlcov .coverage
