variable "create" {
  description = "Whether to create any resource at all. Lets a caller (or the wrapper) disable one instance without removing its configuration."
  type        = bool
  default     = true
}

variable "name" {
  description = "Base name of the SNS topic. Each queue is named \"<name>-<queue key>\" and its dead-letter queue \"<name>-<queue key>-dlq\"."
  type        = string

  validation {
    # SQS allows up to 80 characters; "-<queue key>-dlq" needs room, so the
    # base name is limited to 40 (queue keys are limited to 30 below).
    condition     = can(regex("^[a-zA-Z0-9_-]{1,40}$", var.name))
    error_message = "name must be 1-40 characters: letters, digits, hyphens and underscores only."
  }
}

variable "create_topic" {
  description = "Whether to create an SNS topic and subscribe every queue to it (fan-out). When false, only the queues are created."
  type        = bool
  default     = true
}

variable "queues" {
  description = <<-EOT
    Queues to create, keyed by a short name. Every attribute is optional:
    - visibility_timeout_seconds: 0-43200 (AWS default 30).
    - message_retention_seconds: 60-1209600 (AWS default 345600, 4 days).
    - receive_wait_time_seconds: 0-20, long polling (AWS default 0).
    - create_dlq: create a dead-letter queue and a redrive policy (default true).
    - max_receive_count: receives before a message moves to the DLQ (default 5).
    - dlq_message_retention_seconds: retention of the DLQ (default 1209600, 14 days).
    - raw_message_delivery: SNS delivers the raw message, not the JSON envelope (default true).
    - filter_policy: SNS subscription filter policy, as a JSON string (default null = every message).
  EOT
  type = map(object({
    visibility_timeout_seconds    = optional(number, 30)
    message_retention_seconds     = optional(number, 345600)
    receive_wait_time_seconds     = optional(number, 0)
    create_dlq                    = optional(bool, true)
    max_receive_count             = optional(number, 5)
    dlq_message_retention_seconds = optional(number, 1209600)
    raw_message_delivery          = optional(bool, true)
    filter_policy                 = optional(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for k in keys(var.queues) : can(regex("^[a-zA-Z0-9_-]{1,30}$", k))])
    error_message = "Every queue key must be 1-30 characters: letters, digits, hyphens and underscores only."
  }

  validation {
    condition     = alltrue([for q in values(var.queues) : q.visibility_timeout_seconds >= 0 && q.visibility_timeout_seconds <= 43200])
    error_message = "visibility_timeout_seconds must be between 0 and 43200 (AWS limit)."
  }

  validation {
    condition = alltrue([for q in values(var.queues) :
      q.message_retention_seconds >= 60 && q.message_retention_seconds <= 1209600 &&
    q.dlq_message_retention_seconds >= 60 && q.dlq_message_retention_seconds <= 1209600])
    error_message = "message_retention_seconds and dlq_message_retention_seconds must be between 60 and 1209600 (AWS limit)."
  }

  validation {
    condition     = alltrue([for q in values(var.queues) : q.receive_wait_time_seconds >= 0 && q.receive_wait_time_seconds <= 20])
    error_message = "receive_wait_time_seconds must be between 0 and 20 (AWS limit)."
  }

  validation {
    condition     = alltrue([for q in values(var.queues) : q.max_receive_count >= 1])
    error_message = "max_receive_count must be at least 1."
  }
}

variable "kms_master_key_id" {
  description = "KMS key (ID, ARN or alias) that encrypts the SNS topic at rest. null leaves the topic unencrypted; the queues are still encrypted (sqs_managed_sse_enabled)."
  type        = string
  default     = null
}

variable "sqs_managed_sse_enabled" {
  description = "Encrypt messages at rest with SQS-owned keys (SSE-SQS) on every queue."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags added to every resource (merged with the provider's default_tags)."
  type        = map(string)
  default     = {}
}
