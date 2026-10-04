variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name: dev, stg or prd."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "environment must be dev, stg or prd."
  }
}

variable "app_buckets" {
  description = "Buckets created with the public module and for_each: key = bucket purpose, value = whether versioning is enabled."
  type        = map(bool)
  default = {
    assets  = true
    uploads = false
  }
}
