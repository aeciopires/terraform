# Common configuration of the "s3" unit: several buckets from ONE unit,
# using the wrapper the public module ships (a for_each over "items").
#
# Module: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/5.16.1
# Wrapper: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/v5.16.1/wrappers
locals {
  # Settings from the directory hierarchy (see live/root.hcl). Found from
  # the unit's directory, because this file is included by the unit.
  common  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  environment = local.env.locals.environment
  name_prefix = "${local.common.locals.prefix}-${local.environment}"
  is_floci    = local.account.locals.target == "floci"
}

terraform {
  source = "tfr:///terraform-aws-modules/s3-bucket/aws//wrappers?version=5.16.1"
}

inputs = {
  # Applied to every bucket unless the item says otherwise.
  defaults = {
    # Lets `destroy` delete non-empty buckets - never in production.
    force_destroy = local.environment != "prd"

    versioning = { enabled = true }

    server_side_encryption_configuration = {
      rule = {
        apply_server_side_encryption_by_default = { sse_algorithm = "AES256" }
      }
    }

    # Block every kind of public access and refuse plain-HTTP requests.
    block_public_acls                     = true
    block_public_policy                   = true
    ignore_public_acls                    = true
    restrict_public_buckets               = true
    attach_deny_insecure_transport_policy = true

    control_object_ownership = true
    object_ownership         = "BucketOwnerEnforced"
  }
}
