# Integration test: creates the resources on floci-gcp (or GCP), checks
# the values the API returned and destroys everything at the end.
# Run (floci-gcp): set -a; source ../../.env; set +a
#                  terraform test -filter=tests/integration.tftest.hcl

variables {
  environment                 = "dev"
  prefix                      = "it"
  uniform_bucket_level_access = false # floci-gcp 0.9.0; use true on GCP
}

run "apply_on_floci_or_gcp" {
  command = apply

  assert {
    condition     = output.topic_id == "projects/${var.project_id}/topics/it-dev-lab03-events"
    error_message = "The topic ID must be returned by Pub/Sub."
  }

  assert {
    condition     = google_storage_bucket.files.versioning[0].enabled
    error_message = "Versioning must be enabled."
  }
}
