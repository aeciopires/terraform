variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
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

variable "queues" {
  description = "Names of the SQS queues subscribed to the topic."
  type        = set(string)
  default     = ["billing"]
}

variable "message_retention_seconds" {
  description = "How long SQS keeps a message (60 to 1209600 seconds)."
  type        = number
  default     = 345600

  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    error_message = "message_retention_seconds must be between 60 and 1209600."
  }
}
