terraform {
  # Works with Terraform and OpenTofu.
  required_version = ">= 1.10"

  required_providers {
    # Writes files on your machine - no cloud account needed.
    local = {
      source  = "hashicorp/local"
      version = "2.9.1"
    }
    # Generates random values (names, passwords) that are kept in the state.
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }
}
