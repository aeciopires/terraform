# Fan-out messaging: one Pub/Sub topic with N pull subscriptions, each with
# an optional dead-letter topic - the GCP counterpart of ../aws-messaging.
#
# References:
# - https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic
# - https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription
# - https://cloud.google.com/pubsub/docs/handling-failures (dead-letter topics and their IAM)

locals {
  subscriptions      = var.create ? var.subscriptions : {}
  dead_letter_subs   = { for k, s in local.subscriptions : k => s if s.create_dead_letter }
  grant_dead_letters = var.grant_dead_letter_permissions && length(local.dead_letter_subs) > 0
  # The Pub/Sub service agent forwards undeliverable messages.
  project_number = local.grant_dead_letters ? coalesce(var.project_number, try(data.google_project.this[0].number, null)) : null
  pubsub_agent   = local.grant_dead_letters ? "serviceAccount:service-${local.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com" : null
}

data "google_project" "this" {
  count = local.grant_dead_letters && var.project_number == null ? 1 : 0

  project_id = var.project_id
}

resource "google_pubsub_topic" "this" {
  count = var.create ? 1 : 0

  project                    = var.project_id
  name                       = var.name
  message_retention_duration = var.message_retention_duration
  labels                     = var.labels
}

resource "google_pubsub_topic" "dead_letter" {
  for_each = local.dead_letter_subs

  project = var.project_id
  name    = "${var.name}-${each.key}-dlq"
  labels  = var.labels
}

# Keeps dead-lettered messages so they can be inspected or replayed.
resource "google_pubsub_subscription" "dead_letter" {
  for_each = local.dead_letter_subs

  project                    = var.project_id
  name                       = "${var.name}-${each.key}-dlq"
  topic                      = google_pubsub_topic.dead_letter[each.key].id
  message_retention_duration = "604800s"
  labels                     = var.labels
}

resource "google_pubsub_subscription" "this" {
  for_each = local.subscriptions

  project                    = var.project_id
  name                       = "${var.name}-${each.key}"
  topic                      = google_pubsub_topic.this[0].id
  ack_deadline_seconds       = each.value.ack_deadline_seconds
  message_retention_duration = each.value.message_retention_duration
  filter                     = each.value.filter
  labels                     = var.labels

  retry_policy {
    minimum_backoff = each.value.minimum_backoff
    maximum_backoff = each.value.maximum_backoff
  }

  dynamic "dead_letter_policy" {
    for_each = each.value.create_dead_letter ? [1] : []

    content {
      dead_letter_topic     = google_pubsub_topic.dead_letter[each.key].id
      max_delivery_attempts = each.value.max_delivery_attempts
    }
  }
}

resource "google_pubsub_topic_iam_member" "dead_letter_publisher" {
  for_each = local.grant_dead_letters ? local.dead_letter_subs : {}

  project = var.project_id
  topic   = google_pubsub_topic.dead_letter[each.key].name
  role    = "roles/pubsub.publisher"
  member  = local.pubsub_agent
}

resource "google_pubsub_subscription_iam_member" "dead_letter_subscriber" {
  for_each = local.grant_dead_letters ? local.dead_letter_subs : {}

  project      = var.project_id
  subscription = google_pubsub_subscription.this[each.key].name
  role         = "roles/pubsub.subscriber"
  member       = local.pubsub_agent
}
