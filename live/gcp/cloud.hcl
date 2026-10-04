# Settings shared by every GCP project, environment and region.
locals {
  cloud = "gcp"

  # Exact provider versions written to each unit's versions_override.tf
  # (root.hcl). Check https://registry.terraform.io/providers/hashicorp/google
  # before upgrading, then run `make tg-plan` to see what changes.
  provider_versions = {
    google      = "8.5.0"
    google-beta = "8.5.0"
  }

  # Exceptions, by unit directory name. The public Cloud Run module 0.34.1
  # requires google/google-beta < 8, so its unit uses the latest 7.x.
  provider_version_overrides = {
    cloud-run = {
      google      = "7.46.1"
      google-beta = "7.46.1"
    }
  }
}
