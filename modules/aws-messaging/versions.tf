terraform {
  # Works with Terraform and OpenTofu. ">=" constraints (not "=") let the
  # caller pin the exact version - a reusable module must never pin it.
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}
