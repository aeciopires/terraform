output "orders_topic_id" {
  description = "ID of the orders topic."
  value       = module.orders.topic_id
}

output "orders_subscriptions" {
  description = "Name of every orders subscription."
  value       = { for k, s in module.orders.subscriptions : k => s.name }
}

output "events" {
  description = "Topic ID and subscription names of every wrapper item."
  value = {
    for k, m in module.events.wrapper : k => {
      topic_id      = m.topic_id
      subscriptions = [for s in values(m.subscriptions) : s.name]
    }
  }
}
