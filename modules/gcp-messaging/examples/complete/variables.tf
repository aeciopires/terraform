variable "project_id" {
  description = "GCP project ID (floci-gcp accepts any ID)."
  type        = string
  default     = "floci-local"
}

variable "project_number" {
  description = "GCP project number; null looks it up (floci-gcp cannot, as it does not emulate Cloud Billing)."
  type        = string
  default     = null
}

variable "prefix" {
  description = "Prefix of every name created by this example."
  type        = string
  default     = "lt-example"
}
