# Wrapper for the root module: creates one copy of the module per entry in
# var.items. Every argument falls back to var.defaults, then to the same
# default the root module uses - the pattern used by terraform-aws-modules
# (https://github.com/terraform-aws-modules/terraform-aws-lambda/tree/master/wrappers).
module "wrapper" {
  source = "../"

  for_each = var.items

  create                  = try(each.value.create, var.defaults.create, true)
  create_topic            = try(each.value.create_topic, var.defaults.create_topic, true)
  name                    = try(each.value.name, var.defaults.name, each.key)
  queues                  = try(each.value.queues, var.defaults.queues, {})
  kms_master_key_id       = try(each.value.kms_master_key_id, var.defaults.kms_master_key_id, null)
  sqs_managed_sse_enabled = try(each.value.sqs_managed_sse_enabled, var.defaults.sqs_managed_sse_enabled, true)
  tags                    = merge(try(var.defaults.tags, {}), try(each.value.tags, {}))
}
