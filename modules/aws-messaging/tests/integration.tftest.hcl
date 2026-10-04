# Integration test: really creates the resources, checks them and destroys
# them at the end. Point it at floci (free) or at a real AWS account:
#   floci:    set -a; source .env; set +a   (AWS_ENDPOINT_URL=http://localhost.floci.io:4566)
#   real AWS: your usual credentials, without AWS_ENDPOINT_URL (billed)
# Run: terraform test -filter=tests/integration.tftest.hcl (or tofu test ...)

provider "aws" {
  region = "us-east-1"
}

variables {
  name = "it-orders"
  queues = {
    billing = { max_receive_count = 2 }
  }
}

run "apply_and_check_real_resources" {
  command = apply

  assert {
    condition     = can(regex("^arn:aws:sns:[a-z0-9-]+:[0-9]{12}:it-orders$", output.topic_arn))
    error_message = "The topic ARN returned by the API must be well formed."
  }

  assert {
    condition     = can(regex("^arn:aws:sqs:[a-z0-9-]+:[0-9]{12}:it-orders-billing$", output.queues["billing"].arn))
    error_message = "The queue ARN returned by the API must be well formed."
  }

  assert {
    condition     = output.dead_letter_queues["billing"].name == "it-orders-billing-dlq"
    error_message = "The dead-letter queue must exist."
  }

  assert {
    condition     = jsondecode(aws_sqs_queue_policy.this["billing"].policy).Statement[0].Condition.ArnEquals["aws:SourceArn"] == output.topic_arn
    error_message = "The queue policy must only allow the module's topic."
  }
}
