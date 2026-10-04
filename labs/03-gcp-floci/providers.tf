# Nothing here is specific to floci-gcp: with the GOOGLE_*_CUSTOM_ENDPOINT
# variables set (see ../../.env.example) every API call goes to floci-gcp;
# without them, to Google Cloud.
provider "google" {
  project = var.project_id
  region  = var.region

  # Labels added to every resource that supports labels.
  default_labels = local.labels
}
