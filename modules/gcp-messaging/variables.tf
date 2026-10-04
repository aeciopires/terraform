variable "create" {
  description = "Whether to create any resource at all. Lets a caller (or the wrapper) disable one instance without removing its configuration."
  type        = bool
  default     = true
}

variable "project_id" {
  description = "ID of the GCP project where every resource is created."
  type        = string
}

variable "project_number" {
  description = "Number of the project, used to build the Pub/Sub service agent e-mail. null looks it up with the google_project data source (which also reads the project's billing info)."
  type        = string
  default     = null

  validation {
    condition     = var.project_number == null || can(regex("^[0-9]+$", var.project_number))
    error_message = "project_number must contain digits only."
  }
}

variable "name" {
  description = "Name of the Pub/Sub topic. Each subscription is named \"<name>-<subscription key>\"; dead-letter topics \"<name>-<subscription key>-dlq\"."
  type        = string

  validation {
    # Pub/Sub names: 3-255 characters, starting with a letter, and not
    # starting with "goog". Room is left for the suffixes added above.
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_.~+%-]{2,200}$", var.name)) && !startswith(lower(var.name), "goog")
    error_message = "name must start with a letter, have 3-201 characters (letters, digits, - _ . ~ + %) and must not start with \"goog\"."
  }
}

variable "message_retention_duration" {
  description = "How long the topic keeps messages, e.g. \"86400s\". null keeps the Pub/Sub default (no topic retention)."
  type        = string
  default     = null
}

variable "subscriptions" {
  description = <<-EOT
    Pull subscriptions to create, keyed by a short name. Every attribute is optional:
    - ack_deadline_seconds: 10-600 (default 20).
    - message_retention_duration: e.g. "604800s" (default, 7 days).
    - filter: Pub/Sub filter expression on message attributes (default null = every message).
    - create_dead_letter: create a dead-letter topic and policy (default true).
    - max_delivery_attempts: 5-100 deliveries before dead-lettering (default 5).
    - minimum_backoff / maximum_backoff: retry policy, e.g. "10s" / "600s".
  EOT
  type = map(object({
    ack_deadline_seconds       = optional(number, 20)
    message_retention_duration = optional(string, "604800s")
    filter                     = optional(string)
    create_dead_letter         = optional(bool, true)
    max_delivery_attempts      = optional(number, 5)
    minimum_backoff            = optional(string, "10s")
    maximum_backoff            = optional(string, "600s")
  }))
  default = {}

  validation {
    condition     = alltrue([for k in keys(var.subscriptions) : can(regex("^[a-z0-9-]{1,30}$", k))])
    error_message = "Every subscription key must be 1-30 characters: lower-case letters, digits and hyphens."
  }

  validation {
    condition     = alltrue([for s in values(var.subscriptions) : s.ack_deadline_seconds >= 10 && s.ack_deadline_seconds <= 600])
    error_message = "ack_deadline_seconds must be between 10 and 600 (Pub/Sub limit)."
  }

  validation {
    condition     = alltrue([for s in values(var.subscriptions) : s.max_delivery_attempts >= 5 && s.max_delivery_attempts <= 100])
    error_message = "max_delivery_attempts must be between 5 and 100 (Pub/Sub limit)."
  }
}

variable "grant_dead_letter_permissions" {
  description = "Grant the Pub/Sub service agent publisher on each dead-letter topic and subscriber on each source subscription, as Pub/Sub requires for dead-lettering."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels added to every resource (merged with the provider's default_labels). Keys and values: lower case."
  type        = map(string)
  default     = {}
}
