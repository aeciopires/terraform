# A GCP "account" - for Google Cloud, a project - served by floci-gcp, the
# local GCP emulator: free, no credentials, any project ID works.
#
# To use a real project, copy this directory to live/gcp/<project-name>,
# set target = "real", the real project_id, its project_number (or null to
# look it up) and a state_location, then authenticate with
# `gcloud auth application-default login`. See docs/06-terragrunt.md.
locals {
  account_name = "floci-local"
  project_id   = "floci-local"
  target       = "floci" # floci | real

  # floci-gcp 0.9.0 does not emulate Cloud Billing, which the
  # google_project data source reads, so the number is given here. Get it
  # with: curl -s http://localhost:4588/v1/projects/floci-local | jq -r .projectNumber
  project_number = "999416577709"

  state_location = "US"
}
