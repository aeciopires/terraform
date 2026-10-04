# Unit tests: no cloud, no credentials (mock_provider).
# Run: terraform test -filter=tests/unit.tftest.hcl   (or tofu test ...)

mock_provider "google" {}

variables {
  environment = "dev"
  project_id  = "unit-project"
}

run "names_follow_the_convention" {
  command = apply

  assert {
    condition     = google_storage_bucket.files.name == "lt-dev-unit-project-lab03"
    error_message = "The bucket name must be <prefix>-<env>-<project>-lab03."
  }

  assert {
    condition     = google_pubsub_subscription.this["billing"].name == "lt-dev-lab03-billing"
    error_message = "Subscriptions must be named <prefix>-<env>-lab03-<name>."
  }

  assert {
    condition     = google_storage_bucket.files.uniform_bucket_level_access && google_storage_bucket.files.public_access_prevention == "enforced"
    error_message = "The bucket must be IAM-only and never public by default."
  }
}

run "stg_values_create_two_subscriptions" {
  command = apply

  variables {
    environment   = "stg"
    subscriptions = ["billing", "shipping"]
  }

  assert {
    condition     = length(google_pubsub_subscription.this) == 2
    error_message = "One subscription per name."
  }
}

run "rejects_an_unknown_environment" {
  command = plan

  variables {
    environment = "qa"
  }

  expect_failures = [var.environment]
}
