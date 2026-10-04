variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "prefix" {
  description = "Prefix of every name created by this example."
  type        = string
  default     = "lt-example"
}
