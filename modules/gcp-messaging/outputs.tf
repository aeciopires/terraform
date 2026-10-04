output "topic_id" {
  description = "ID of the topic (projects/{project}/topics/{name}); null when create = false."
  value       = try(google_pubsub_topic.this[0].id, null)
}

output "topic_name" {
  description = "Name of the topic; null when create = false."
  value       = try(google_pubsub_topic.this[0].name, null)
}

output "subscriptions" {
  description = "Map of subscription key => { name, id } of every subscription."
  value = {
    for k, s in google_pubsub_subscription.this : k => {
      name = s.name
      id   = s.id
    }
  }
}

output "dead_letter_topics" {
  description = "Map of subscription key => { name, id } of every dead-letter topic."
  value = {
    for k, t in google_pubsub_topic.dead_letter : k => {
      name = t.name
      id   = t.id
    }
  }
}
