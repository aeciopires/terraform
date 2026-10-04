# Unit "orders-messaging": a one-off, fully customized instance OUTSIDE the
# wrapper's loop - it calls modules/gcp-messaging directly, with settings
# no other instance shares.
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

terraform {
  source = "${get_repo_root()}/modules/gcp-messaging"
}

inputs = {
  project_id                 = include.root.locals.account_id
  project_number             = try(local.account.locals.project_number, null)
  name                       = "${include.root.locals.name_prefix}-orders"
  message_retention_duration = "86400s" # the topic keeps 1 day of messages

  subscriptions = {
    billing = {
      ack_deadline_seconds  = 120
      max_delivery_attempts = 10
      filter                = "attributes.type = \"order_paid\""
    }
    shipping = {
      filter = "attributes.type = \"order_paid\" OR attributes.type = \"order_cancelled\""
    }
  }
}
