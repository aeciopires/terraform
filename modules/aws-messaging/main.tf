# Fan-out messaging: one SNS topic delivering to N SQS queues, each with an
# optional dead-letter queue (DLQ).
#
# References:
# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue
# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription
# - https://docs.aws.amazon.com/sns/latest/dg/sns-sqs-as-subscriber.html
# - https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-dead-letter-queues.html

locals {
  queues      = var.create ? var.queues : {}
  dlq_queues  = { for k, q in local.queues : k => q if q.create_dlq }
  topic_count = var.create && var.create_topic ? 1 : 0
}

# Topic encryption is opt-in (kms_master_key_id): a customer managed KMS key
# has a monthly cost and a key policy that every publisher must be allowed
# by. Trivy flags the unencrypted default (AWS-0095); this is a conscious,
# documented choice, so the finding is ignored here - see docs/07-testes.md.
#trivy:ignore:AWS-0095
resource "aws_sns_topic" "this" {
  count = local.topic_count

  name              = var.name
  kms_master_key_id = var.kms_master_key_id
  tags              = var.tags
}

resource "aws_sqs_queue" "dlq" {
  for_each = local.dlq_queues

  name                      = "${var.name}-${each.key}-dlq"
  message_retention_seconds = each.value.dlq_message_retention_seconds
  sqs_managed_sse_enabled   = var.sqs_managed_sse_enabled
  tags                      = var.tags
}

resource "aws_sqs_queue" "this" {
  for_each = local.queues

  name                       = "${var.name}-${each.key}"
  visibility_timeout_seconds = each.value.visibility_timeout_seconds
  message_retention_seconds  = each.value.message_retention_seconds
  receive_wait_time_seconds  = each.value.receive_wait_time_seconds
  sqs_managed_sse_enabled    = var.sqs_managed_sse_enabled
  tags                       = var.tags
}

# The provider docs recommend the standalone redrive resources over the
# inline redrive_policy argument.
resource "aws_sqs_queue_redrive_policy" "this" {
  for_each = local.dlq_queues

  queue_url = aws_sqs_queue.this[each.key].id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = each.value.max_receive_count
  })
}

# Only the matching source queue may use a DLQ as its dead-letter target.
resource "aws_sqs_queue_redrive_allow_policy" "this" {
  for_each = local.dlq_queues

  queue_url = aws_sqs_queue.dlq[each.key].id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.this[each.key].arn]
  })
}

# Allows the topic (and only the topic) to send messages to each queue.
data "aws_iam_policy_document" "queue" {
  for_each = local.topic_count == 1 ? local.queues : {}

  statement {
    sid       = "AllowSnsTopic"
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.this[each.key].arn]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.this[0].arn]
    }
  }
}

resource "aws_sqs_queue_policy" "this" {
  for_each = local.topic_count == 1 ? local.queues : {}

  queue_url = aws_sqs_queue.this[each.key].id
  policy    = data.aws_iam_policy_document.queue[each.key].json
}

resource "aws_sns_topic_subscription" "this" {
  for_each = local.topic_count == 1 ? local.queues : {}

  topic_arn            = aws_sns_topic.this[0].arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.this[each.key].arn
  raw_message_delivery = each.value.raw_message_delivery
  filter_policy        = each.value.filter_policy

  # The queue policy must exist before SNS starts delivering.
  depends_on = [aws_sqs_queue_policy.this]
}
