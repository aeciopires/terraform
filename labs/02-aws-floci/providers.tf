# Nothing here is specific to floci: with AWS_ENDPOINT_URL set (see
# ../../.env.example) every API call goes to floci; without it, to AWS.
provider "aws" {
  region = var.region

  # Tags added to every resource that supports tags.
  default_tags {
    tags = local.tags
  }
}
