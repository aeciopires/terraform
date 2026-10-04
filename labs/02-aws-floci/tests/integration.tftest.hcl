# Integration test: creates the resources on floci (or AWS), checks the
# values the API returned and destroys everything at the end.
# Run (floci): set -a; source ../../.env; set +a
#              terraform test -filter=tests/integration.tftest.hcl

variables {
  environment = "dev"
  prefix      = "it"
}

run "apply_on_floci_or_aws" {
  command = apply

  assert {
    condition     = can(regex("^[0-9]{12}$", output.account_id))
    error_message = "The account ID must come from STS."
  }

  assert {
    condition     = aws_s3_bucket_versioning.files.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning must be enabled."
  }

  assert {
    condition     = startswith(output.topic_arn, "arn:aws:sns:")
    error_message = "The topic ARN must be returned by SNS."
  }
}
