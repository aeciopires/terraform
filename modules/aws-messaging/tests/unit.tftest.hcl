# Unit tests: no cloud, no credentials. mock_provider replaces the real AWS
# provider with one that returns fake values for computed attributes, so
# even "command = apply" creates nothing.
# Run: terraform test -filter=tests/unit.tftest.hcl (or tofu test ...)
#
# References:
# - https://developer.hashicorp.com/terraform/language/tests
# - https://developer.hashicorp.com/terraform/language/tests/mocking
# - https://opentofu.org/docs/cli/commands/test/

mock_provider "aws" {
  # The IAM policy document data source must return valid JSON, because
  # aws_sqs_queue_policy validates it.
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  # ARNs are validated by the resources that receive them, so the random
  # strings the mock would generate are replaced by well-formed ones.
  mock_resource "aws_sns_topic" {
    defaults = {
      arn = "arn:aws:sns:us-east-1:123456789012:mock-topic"
    }
  }

  mock_resource "aws_sqs_queue" {
    defaults = {
      arn = "arn:aws:sqs:us-east-1:123456789012:mock-queue"
      url = "https://sqs.us-east-1.amazonaws.com/123456789012/mock-queue"
    }
  }
}

variables {
  name = "unit-orders"
  queues = {
    billing  = { max_receive_count = 3 }
    shipping = { create_dlq = false, filter_policy = "{\"type\":[\"shipping\"]}" }
  }
  tags = { Domain = "orders" }
}

run "creates_topic_queues_and_dlqs" {
  command = apply

  assert {
    condition     = length(aws_sns_topic.this) == 1 && aws_sns_topic.this[0].name == "unit-orders"
    error_message = "Expected exactly one topic named unit-orders."
  }

  assert {
    condition     = toset([for q in aws_sqs_queue.this : q.name]) == toset(["unit-orders-billing", "unit-orders-shipping"])
    error_message = "Queues must be named <name>-<queue key>."
  }

  assert {
    condition     = keys(aws_sqs_queue.dlq) == ["billing"] && aws_sqs_queue.dlq["billing"].name == "unit-orders-billing-dlq"
    error_message = "Only queues with create_dlq = true get a dead-letter queue."
  }

  assert {
    condition     = jsondecode(aws_sqs_queue_redrive_policy.this["billing"].redrive_policy).maxReceiveCount == 3
    error_message = "max_receive_count must reach the redrive policy."
  }

  assert {
    condition     = length(aws_sns_topic_subscription.this) == 2 && alltrue([for s in aws_sns_topic_subscription.this : s.protocol == "sqs" && s.raw_message_delivery])
    error_message = "Every queue must be subscribed to the topic with raw message delivery."
  }

  assert {
    condition     = aws_sns_topic_subscription.this["shipping"].filter_policy == "{\"type\":[\"shipping\"]}"
    error_message = "filter_policy must reach the subscription."
  }

  assert {
    condition     = alltrue([for q in aws_sqs_queue.this : q.sqs_managed_sse_enabled && q.tags["Domain"] == "orders"])
    error_message = "Queues must be encrypted (SSE-SQS) and tagged."
  }
}

run "queues_only_without_topic" {
  command = apply

  variables {
    create_topic = false
  }

  assert {
    condition     = length(aws_sns_topic.this) == 0 && length(aws_sns_topic_subscription.this) == 0 && length(aws_sqs_queue_policy.this) == 0
    error_message = "create_topic = false must not create the topic, the subscriptions or the queue policies."
  }

  assert {
    condition     = output.topic_arn == null && length(output.queues) == 2
    error_message = "Outputs must still list the queues and return a null topic ARN."
  }
}

run "topic_encrypted_with_kms_when_requested" {
  command = apply

  variables {
    kms_master_key_id = "alias/aws/sns"
  }

  assert {
    condition     = aws_sns_topic.this[0].kms_master_key_id == "alias/aws/sns"
    error_message = "kms_master_key_id must reach the topic."
  }
}

run "create_false_creates_nothing" {
  command = apply

  variables {
    create = false
  }

  assert {
    condition     = length(aws_sns_topic.this) == 0 && length(aws_sqs_queue.this) == 0 && length(aws_sqs_queue.dlq) == 0
    error_message = "create = false must create nothing."
  }
}

run "rejects_invalid_name" {
  command = plan

  variables {
    name = "invalid name with spaces"
  }

  expect_failures = [var.name]
}

run "rejects_out_of_range_retention" {
  command = plan

  variables {
    queues = { bad = { message_retention_seconds = 30 } }
  }

  expect_failures = [var.queues]
}

run "rejects_long_queue_key" {
  command = plan

  variables {
    queues = { this-queue-key-is-way-too-long-for-sqs = {} }
  }

  expect_failures = [var.queues]
}
