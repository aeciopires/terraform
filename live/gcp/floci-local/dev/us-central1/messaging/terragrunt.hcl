# Unit "messaging": several Pub/Sub fan-outs from ONE unit, through the
# wrapper of modules/gcp-messaging. Defaults come from
# _envcommon/gcp/messaging.hcl; each item only says what differs.
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/gcp/messaging.hcl"
  expose         = true
  merge_strategy = "deep"
}

inputs = {
  items = {
    "${include.root.locals.name_prefix}-audit" = {}
    "${include.root.locals.name_prefix}-emails" = {
      subscriptions = { sender = { create_dead_letter = false } }
    }
  }
}
