output "orders_topic_arn" {
  description = "ARN of the orders topic."
  value       = module.orders.topic_arn
}

output "orders_queue_urls" {
  description = "URL of every orders queue."
  value       = { for k, q in module.orders.queues : k => q.url }
}

output "events" {
  description = "Topic ARN and queue names of every wrapper item."
  value = {
    for k, m in module.events.wrapper : k => {
      topic_arn = m.topic_arn
      queues    = [for q in values(m.queues) : q.name]
    }
  }
}
