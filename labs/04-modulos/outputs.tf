output "logs_bucket" {
  description = "Name of the logs bucket (module 1)."
  value       = module.logs_bucket.s3_bucket_id
}

output "app_buckets" {
  description = "Name of every app bucket (module 2, for_each)."
  value       = { for k, m in module.app_buckets : k => m.s3_bucket_id }
}

output "messaging" {
  description = "Topic ARN and queues of every wrapper item (module 3)."
  value = {
    for k, m in module.messaging.wrapper : k => {
      topic_arn = m.topic_arn
      queues    = [for q in values(m.queues) : q.name]
    }
  }
}

output "orders_topic_arn" {
  description = "ARN of the orders topic (module 4)."
  value       = module.orders.topic_arn
}
