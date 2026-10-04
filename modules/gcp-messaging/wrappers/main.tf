# Wrapper for the root module: creates one copy of the module per entry in
# var.items. Every argument falls back to var.defaults, then to the same
# default the root module uses - the pattern used by terraform-aws-modules
# (https://github.com/terraform-aws-modules/terraform-aws-lambda/tree/master/wrappers).
module "wrapper" {
  source = "../"

  for_each = var.items

  create                        = try(each.value.create, var.defaults.create, true)
  project_id                    = try(each.value.project_id, var.defaults.project_id)
  project_number                = try(each.value.project_number, var.defaults.project_number, null)
  name                          = try(each.value.name, var.defaults.name, each.key)
  message_retention_duration    = try(each.value.message_retention_duration, var.defaults.message_retention_duration, null)
  subscriptions                 = try(each.value.subscriptions, var.defaults.subscriptions, {})
  grant_dead_letter_permissions = try(each.value.grant_dead_letter_permissions, var.defaults.grant_dead_letter_permissions, true)
  labels                        = merge(try(var.defaults.labels, {}), try(each.value.labels, {}))
}
