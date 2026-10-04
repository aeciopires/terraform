# Complete example: the module called directly and through its wrapper.
# Provider credentials and endpoints come from the environment, so the same
# code runs against floci (AWS_ENDPOINT_URL set) and a real AWS account.

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Product     = "learning-terraform"
      Environment = "example"
      ManagedBy   = "terraform"
    }
  }
}

# One instance, with every option visible.
module "orders" {
  source = "../../"

  name = "${var.prefix}-orders"

  queues = {
    billing = {
      max_receive_count = 3
    }
    shipping = {
      visibility_timeout_seconds = 60
      filter_policy              = jsonencode({ type = ["shipping"] })
    }
  }

  tags = { Domain = "orders" }
}

# Many instances from one block: the wrapper loops over "items" and fills
# every missing argument from "defaults".
module "events" {
  source = "../../wrappers"

  defaults = {
    queues = { worker = {} }
    tags   = { Domain = "events" }
  }

  items = {
    "${var.prefix}-audit"  = {}
    "${var.prefix}-emails" = { create_topic = false }
  }
}
