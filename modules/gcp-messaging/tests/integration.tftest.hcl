# Integration test: really creates the resources, checks them and destroys
# them at the end. Point it at floci-gcp (free) or at a real GCP project:
#   floci-gcp: set -a; source .env; set +a   (GOOGLE_*_CUSTOM_ENDPOINT=http://localhost:4588/...)
#   real GCP:  gcloud auth application-default login, without the floci
#              variables; -var project_id=<your-project> -var project_number=<its number> (billed)
# Run: terraform test -filter=tests/integration.tftest.hcl (or tofu test ...)

variables {
  project_id = "floci-local"
  # floci-gcp does not emulate Cloud Billing, which the google_project data
  # source reads; on a real project you can leave project_number unset.
  project_number = "999416577709"
  name           = "it-orders"
  subscriptions = {
    billing = {}
  }
}

provider "google" {
  project = var.project_id
}

run "apply_and_check_real_resources" {
  command = apply

  assert {
    condition     = output.topic_id == "projects/${var.project_id}/topics/it-orders"
    error_message = "The topic ID returned by the API must be well formed."
  }

  assert {
    condition     = output.subscriptions["billing"].id == "projects/${var.project_id}/subscriptions/it-orders-billing"
    error_message = "The subscription must exist."
  }

  assert {
    condition     = google_pubsub_subscription.this["billing"].dead_letter_policy[0].dead_letter_topic == output.dead_letter_topics["billing"].id
    error_message = "The subscription must dead-letter to its own dead-letter topic."
  }
}
