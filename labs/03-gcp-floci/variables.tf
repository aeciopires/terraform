variable "project_id" {
  description = "GCP project ID (floci-gcp accepts any ID)."
  type        = string
  default     = "floci-local"
}

variable "region" {
  description = "GCP region."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name: dev, stg or prd."
  type        = string

  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "environment must be dev, stg or prd."
  }
}

variable "prefix" {
  description = "Short product name, the start of every resource name."
  type        = string
  default     = "lt"
}

variable "subscriptions" {
  description = "Names of the Pub/Sub subscriptions of the topic."
  type        = set(string)
  default     = ["billing"]
}

variable "uniform_bucket_level_access" {
  description = "IAM-only access to the bucket (recommended). floci-gcp 0.9.0 does not keep it: use false there."
  type        = bool
  default     = true
}
