terraform {
  # Works with Terraform and OpenTofu. ">=" constraints (not "=") let the
  # caller pin the exact version - a reusable module must never pin it.
  required_version = ">= 1.10"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.0"
    }
  }
}
