output "account_id" {
  description = "Account the resources were created in (000000000000 on floci)."
  value       = data.aws_caller_identity.current.account_id
}

output "bucket_name" {
  description = "Name of the S3 bucket."
  value       = aws_s3_bucket.files.bucket
}

output "topic_arn" {
  description = "ARN of the SNS topic."
  value       = aws_sns_topic.events.arn
}

output "queue_urls" {
  description = "URL of every SQS queue."
  value       = { for k, q in aws_sqs_queue.this : k => q.url }
}
