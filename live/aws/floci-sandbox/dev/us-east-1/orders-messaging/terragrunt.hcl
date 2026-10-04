# Unit "orders-messaging": a one-off, fully customized instance OUTSIDE the
# wrapper's loop - it calls modules/aws-messaging directly, with settings
# no other instance shares.
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/modules/aws-messaging"
}

inputs = {
  name = "${include.root.locals.name_prefix}-orders"

  queues = {
    billing = {
      visibility_timeout_seconds = 120
      max_receive_count          = 3
      filter_policy              = jsonencode({ type = ["order_paid"] })
    }
    shipping = {
      receive_wait_time_seconds = 20 # long polling
      filter_policy             = jsonencode({ type = ["order_paid", "order_cancelled"] })
    }
  }
}
