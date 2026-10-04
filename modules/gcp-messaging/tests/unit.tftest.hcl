# Unit tests: no cloud, no credentials. mock_provider replaces the real
# Google provider with one that returns fake values for computed
# attributes, so even "command = apply" creates nothing.
# Run: terraform test -filter=tests/unit.tftest.hcl (or tofu test ...)
#
# References:
# - https://developer.hashicorp.com/terraform/language/tests/mocking
# - https://opentofu.org/docs/cli/commands/test/

mock_provider "google" {
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }
}

variables {
  project_id = "unit-project"
  name       = "unit-orders"
  subscriptions = {
    billing  = { max_delivery_attempts = 10 }
    shipping = { create_dead_letter = false, filter = "attributes.type = \"shipping\"" }
  }
  labels = { domain = "orders" }
}

run "creates_topic_subscriptions_and_dead_letters" {
  command = apply

  assert {
    condition     = google_pubsub_topic.this[0].name == "unit-orders" && google_pubsub_topic.this[0].project == "unit-project"
    error_message = "Expected one topic named unit-orders in unit-project."
  }

  assert {
    condition     = toset([for s in google_pubsub_subscription.this : s.name]) == toset(["unit-orders-billing", "unit-orders-shipping"])
    error_message = "Subscriptions must be named <name>-<subscription key>."
  }

  assert {
    condition     = keys(google_pubsub_topic.dead_letter) == ["billing"] && google_pubsub_topic.dead_letter["billing"].name == "unit-orders-billing-dlq"
    error_message = "Only subscriptions with create_dead_letter = true get a dead-letter topic."
  }

  assert {
    condition     = google_pubsub_subscription.this["billing"].dead_letter_policy[0].max_delivery_attempts == 10
    error_message = "max_delivery_attempts must reach the dead-letter policy."
  }

  assert {
    condition     = length(google_pubsub_subscription.this["shipping"].dead_letter_policy) == 0 && google_pubsub_subscription.this["shipping"].filter == "attributes.type = \"shipping\""
    error_message = "shipping must have its filter and no dead-letter policy."
  }

  assert {
    condition     = google_pubsub_topic_iam_member.dead_letter_publisher["billing"].member == "serviceAccount:service-123456789012@gcp-sa-pubsub.iam.gserviceaccount.com"
    error_message = "The Pub/Sub service agent must be granted publisher on the dead-letter topic."
  }

  assert {
    condition     = google_pubsub_subscription_iam_member.dead_letter_subscriber["billing"].role == "roles/pubsub.subscriber"
    error_message = "The Pub/Sub service agent must be granted subscriber on the source subscription."
  }
}

run "no_iam_when_disabled" {
  command = apply

  variables {
    grant_dead_letter_permissions = false
  }

  assert {
    condition     = length(google_pubsub_topic_iam_member.dead_letter_publisher) == 0 && length(data.google_project.this) == 0
    error_message = "grant_dead_letter_permissions = false must not look up the project or grant roles."
  }
}

run "project_number_skips_the_lookup" {
  command = apply

  variables {
    project_number = "42"
  }

  assert {
    condition     = length(data.google_project.this) == 0 && google_pubsub_topic_iam_member.dead_letter_publisher["billing"].member == "serviceAccount:service-42@gcp-sa-pubsub.iam.gserviceaccount.com"
    error_message = "A given project_number must be used without looking the project up."
  }
}

run "create_false_creates_nothing" {
  command = apply

  variables {
    create = false
  }

  assert {
    condition     = length(google_pubsub_topic.this) == 0 && length(google_pubsub_subscription.this) == 0 && output.topic_id == null
    error_message = "create = false must create nothing."
  }
}

run "rejects_name_starting_with_goog" {
  command = plan

  variables {
    name = "google-events"
  }

  expect_failures = [var.name]
}

run "rejects_too_few_delivery_attempts" {
  command = plan

  variables {
    subscriptions = { bad = { max_delivery_attempts = 2 } }
  }

  expect_failures = [var.subscriptions]
}

run "rejects_ack_deadline_out_of_range" {
  command = plan

  variables {
    subscriptions = { bad = { ack_deadline_seconds = 900 } }
  }

  expect_failures = [var.subscriptions]
}
