# Lab 03: Google Cloud resources written directly (no modules) - a Cloud
# Storage bucket and a Pub/Sub topic with subscriptions - run against
# floci-gcp.
#
# References:
# - https://registry.terraform.io/providers/hashicorp/google/8.5.0/docs/resources/storage_bucket
# - https://registry.terraform.io/providers/hashicorp/google/8.5.0/docs/resources/pubsub_topic
# - https://registry.terraform.io/providers/hashicorp/google/8.5.0/docs/resources/pubsub_subscription

locals {
  name_prefix = "${var.prefix}-${var.environment}"
  # GCP labels: lower-case letters, digits, "_" and "-" only.
  labels = {
    product     = "learning-terraform"
    environment = var.environment
    managed-by  = "terraform"
    lab         = "03-gcp-floci"
  }
}

resource "google_storage_bucket" "files" {
  # Bucket names are global: the project ID makes this one unique.
  name                        = "${local.name_prefix}-${var.project_id}-lab03"
  location                    = "US"
  force_destroy               = var.environment != "prd"
  uniform_bucket_level_access = var.uniform_bucket_level_access
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }
}

resource "google_pubsub_topic" "events" {
  name = "${local.name_prefix}-lab03-events"
}

resource "google_pubsub_subscription" "this" {
  for_each = var.subscriptions

  name                       = "${local.name_prefix}-lab03-${each.key}"
  topic                      = google_pubsub_topic.events.id
  ack_deadline_seconds       = 20
  message_retention_duration = "604800s" # 7 days
}
