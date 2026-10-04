# TFLint configuration shared by every directory the Makefile lints
# (`make lint` runs `tflint --chdir <dir> --config <this file>`).
# `tflint --init` downloads the plugins below (set GITHUB_TOKEN to avoid
# GitHub API rate limits).
#
# References:
# - https://github.com/terraform-linters/tflint/blob/v0.64.0/docs/user-guide/config.md
# - https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.15.0/docs/rules/README.md
config {
  # Also lint the modules a configuration calls.
  call_module_type = "local"
}

# Terraform language rules (naming, unused declarations, pinned versions...).
plugin "terraform" {
  enabled = true
  preset  = "recommended"
  version = "0.15.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

# AWS rules: invalid instance types, regions, deprecated arguments...
plugin "aws" {
  enabled = true
  version = "0.49.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Google Cloud rules: invalid machine types, regions...
plugin "google" {
  enabled = true
  version = "0.40.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

# Every variable and output needs a description - terraform-docs prints it.
rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}
