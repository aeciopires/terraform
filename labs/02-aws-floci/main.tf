# Lab 02: AWS resources written directly (no modules) - an S3 bucket, an
# SNS topic and SQS queues subscribed to it - run against floci.
#
# References:
# - https://registry.terraform.io/providers/hashicorp/aws/6.67.0/docs/resources/s3_bucket
# - https://registry.terraform.io/providers/hashicorp/aws/6.67.0/docs/resources/sns_topic
# - https://registry.terraform.io/providers/hashicorp/aws/6.67.0/docs/resources/sqs_queue

data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.prefix}-${var.environment}"
  tags = {
    Product     = "learning-terraform"
    Environment = var.environment
    ManagedBy   = "terraform"
    Lab         = "02-aws-floci"
  }
}

resource "aws_s3_bucket" "files" {
  # Bucket names are global: the account ID makes this one unique.
  bucket        = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}-lab02"
  force_destroy = var.environment != "prd"
}

# Since AWS provider v4, bucket settings are separate resources.
resource "aws_s3_bucket_versioning" "files" {
  bucket = aws_s3_bucket.files.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "files" {
  bucket = aws_s3_bucket.files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_sns_topic" "events" {
  name = "${local.name_prefix}-lab02-events"
}

resource "aws_sqs_queue" "this" {
  for_each = var.queues

  name                      = "${local.name_prefix}-lab02-${each.key}"
  message_retention_seconds = var.message_retention_seconds
  sqs_managed_sse_enabled   = true
}

# Only the topic may send messages to the queues.
resource "aws_sqs_queue_policy" "this" {
  for_each = var.queues

  queue_url = aws_sqs_queue.this[each.key].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowSnsTopic"
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.this[each.key].arn
      Condition = { ArnEquals = { "aws:SourceArn" = aws_sns_topic.events.arn } }
    }]
  })
}

resource "aws_sns_topic_subscription" "this" {
  for_each = var.queues

  topic_arn            = aws_sns_topic.events.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.this[each.key].arn
  raw_message_delivery = true
}
