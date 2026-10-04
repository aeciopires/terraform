# Unit tests: no cloud, no credentials (mock_provider).
# Run: terraform test -filter=tests/unit.tftest.hcl   (or tofu test ...)

mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_resource "aws_sns_topic" {
    defaults = {
      arn = "arn:aws:sns:us-east-1:123456789012:mock"
    }
  }

  mock_resource "aws_sqs_queue" {
    defaults = {
      arn = "arn:aws:sqs:us-east-1:123456789012:mock"
    }
  }
}

variables {
  environment = "dev"
}

run "names_follow_the_convention" {
  command = apply

  assert {
    condition     = aws_s3_bucket.files.bucket == "lt-dev-123456789012-lab02"
    error_message = "The bucket name must be <prefix>-<env>-<account>-lab02."
  }

  assert {
    condition     = aws_sqs_queue.this["billing"].name == "lt-dev-lab02-billing"
    error_message = "Queues must be named <prefix>-<env>-lab02-<queue>."
  }
}

run "stg_values_create_two_queues" {
  command = apply

  variables {
    environment               = "stg"
    queues                    = ["billing", "shipping"]
    message_retention_seconds = 604800
  }

  assert {
    condition     = length(aws_sns_topic_subscription.this) == 2
    error_message = "Each queue must be subscribed to the topic."
  }

  assert {
    condition     = aws_sqs_queue.this["shipping"].message_retention_seconds == 604800
    error_message = "message_retention_seconds must reach the queues."
  }
}

run "prd_keeps_non_empty_buckets" {
  command = plan

  variables {
    environment = "prd"
  }

  assert {
    condition     = aws_s3_bucket.files.force_destroy == false
    error_message = "force_destroy must be false in production."
  }
}

run "rejects_short_retention" {
  command = plan

  variables {
    message_retention_seconds = 10
  }

  expect_failures = [var.message_retention_seconds]
}
