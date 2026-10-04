# Lab 04: four ways of calling modules from one root module.
#
# 1. A public module, one instance.
# 2. The same public module many times, with the native for_each.
# 3. This repository's module through its wrapper (a loop with defaults).
# 4. This repository's module directly: a custom instance outside the loop.
#
# Public module: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/5.16.1

data "aws_caller_identity" "current" {}

locals {
  name_prefix   = "lt-${var.environment}"
  bucket_prefix = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}"
}

# 1. Public module, pinned to an exact version. `terraform init` downloads
#    it into .terraform/modules.
module "logs_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.16.1"

  bucket        = "${local.bucket_prefix}-lab04-logs"
  force_destroy = var.environment != "prd"

  lifecycle_rule = [{
    id         = "expire-logs"
    enabled    = true
    filter     = {}
    expiration = { days = 30 }
  }]
}

# 2. The native for_each on a module: one instance per map entry, addressed
#    as module.app_buckets["assets"].
module "app_buckets" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.16.1"

  for_each = var.app_buckets

  bucket        = "${local.bucket_prefix}-lab04-${each.key}"
  force_destroy = var.environment != "prd"
  versioning    = { enabled = each.value }
}

# 3. The wrapper: the same loop, but the common settings are written once in
#    "defaults" - and it works where for_each is not available (Terragrunt
#    calls one module per unit).
module "messaging" {
  source = "../../modules/aws-messaging/wrappers"

  defaults = {
    queues = {
      worker = { max_receive_count = 5 }
    }
  }

  items = {
    "${local.name_prefix}-lab04-audit"  = {}
    "${local.name_prefix}-lab04-emails" = { create_topic = false }
  }
}

# 4. A one-off instance with settings no other instance shares: call the
#    module itself, outside the loop.
module "orders" {
  source = "../../modules/aws-messaging"

  name = "${local.name_prefix}-lab04-orders"

  queues = {
    billing = {
      visibility_timeout_seconds = 120
      max_receive_count          = 3
      filter_policy              = jsonencode({ type = ["order_paid"] })
    }
  }
}
