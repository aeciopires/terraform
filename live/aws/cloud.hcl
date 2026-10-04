# Settings shared by every AWS account, environment and region.
locals {
  cloud = "aws"

  # Exact provider versions written to each unit's versions.tf (root.hcl).
  # Check https://registry.terraform.io/providers/hashicorp/aws before
  # upgrading, then run `make tg-plan` to see what changes.
  provider_versions = {
    aws = "6.67.0"
  }

  # Exceptions, by unit directory name, for a module that does not support
  # the versions above yet (see live/gcp/cloud.hcl for an example).
  provider_version_overrides = {}
}
