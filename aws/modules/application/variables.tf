#-------------------------
# Changes the values default of accord with the necessity
#-------------------------

variable "aws_zone" {
  description = "The zone to operate under, if not specified by a given resource."
  default = "us-east-2"
}

variable "machine_type" {
  description = "Machine Type."
  default = "t2.medium"
}

# Default: Ubuntu 16.04
variable "operating_system" {
  description = "Operating System."
  default = "ami-0552e3455b9bc8d50"
}
