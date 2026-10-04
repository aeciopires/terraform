# Unit "messaging": several SNS+SQS fan-outs from ONE unit, through the
# wrapper of modules/aws-messaging. Defaults come from
# _envcommon/aws/messaging.hcl; each item only says what differs.
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/aws/messaging.hcl"
  expose         = true
  merge_strategy = "deep"
}

inputs = {
  items = {
    "${include.root.locals.name_prefix}-audit" = {}
    "${include.root.locals.name_prefix}-emails" = {
      create_topic = false # queues only, no fan-out
    }
  }
}
