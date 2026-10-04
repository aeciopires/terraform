output "topic_arn" {
  description = "ARN of the SNS topic (null when create_topic = false)."
  value       = try(aws_sns_topic.this[0].arn, null)
}

output "topic_name" {
  description = "Name of the SNS topic (null when create_topic = false)."
  value       = try(aws_sns_topic.this[0].name, null)
}

output "queues" {
  description = "Map of queue key => { name, arn, url } of every queue."
  value = {
    for k, q in aws_sqs_queue.this : k => {
      name = q.name
      arn  = q.arn
      url  = q.url
    }
  }
}

output "dead_letter_queues" {
  description = "Map of queue key => { name, arn, url } of every dead-letter queue."
  value = {
    for k, q in aws_sqs_queue.dlq : k => {
      name = q.name
      arn  = q.arn
      url  = q.url
    }
  }
}

output "subscription_arns" {
  description = "Map of queue key => ARN of its SNS subscription."
  value       = { for k, s in aws_sns_topic_subscription.this : k => s.arn }
}
