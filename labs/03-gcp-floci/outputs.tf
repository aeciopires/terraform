output "bucket_name" {
  description = "Name of the Cloud Storage bucket."
  value       = google_storage_bucket.files.name
}

output "topic_id" {
  description = "ID of the Pub/Sub topic."
  value       = google_pubsub_topic.events.id
}

output "subscription_ids" {
  description = "ID of every subscription."
  value       = { for k, s in google_pubsub_subscription.this : k => s.id }
}
