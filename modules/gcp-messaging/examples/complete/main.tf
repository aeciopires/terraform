# Complete example: the module called directly and through its wrapper.
# Credentials and endpoints come from the environment, so the same code
# runs against floci-gcp (GOOGLE_*_CUSTOM_ENDPOINT set) and a real project.

provider "google" {
  project = var.project_id

  default_labels = {
    product     = "learning-terraform"
    environment = "example"
    managed-by  = "terraform"
  }
}

# One instance, with every option visible.
module "orders" {
  source = "../../"

  project_id     = var.project_id
  project_number = var.project_number
  name           = "${var.prefix}-orders"

  subscriptions = {
    billing = {
      max_delivery_attempts = 10
    }
    shipping = {
      ack_deadline_seconds = 60
      filter               = "attributes.type = \"shipping\""
    }
  }

  labels = { domain = "orders" }
}

# Many instances from one block: the wrapper loops over "items" and fills
# every missing argument from "defaults".
module "events" {
  source = "../../wrappers"

  defaults = {
    project_id     = var.project_id
    project_number = var.project_number
    subscriptions  = { worker = {} }
    labels         = { domain = "events" }
  }

  items = {
    "${var.prefix}-audit"  = {}
    "${var.prefix}-emails" = { subscriptions = { sender = { create_dead_letter = false } } }
  }
}
