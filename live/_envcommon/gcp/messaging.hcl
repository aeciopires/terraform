# Common configuration of the "messaging" unit: several Pub/Sub fan-outs
# from ONE unit, through the wrapper of this repository's own module.
#
# In another repository, use a Git URL pinned to a tag:
#   git::https://github.com/aeciopires/terraform.git//modules/gcp-messaging/wrappers?ref=<tag>
locals {
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${get_repo_root()}/modules/gcp-messaging//wrappers"
}

inputs = {
  defaults = {
    project_id     = try(local.env.locals.project_id, local.account.locals.project_id)
    project_number = try(local.env.locals.project_number, local.account.locals.project_number, null)
    subscriptions = {
      worker = { max_delivery_attempts = 5 }
    }
  }
}
