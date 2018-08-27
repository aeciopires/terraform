#-------------------------
# Changes the values default of accord with the necessity
#-------------------------

variable "gc_project" {
  description = "The ID of the project to apply any resources to."
  default = "aecio-pires"
}

variable "gc_zone" {
  description = "The zone to operate under, if not specified by a given resource."
  default = "us-central1-c"
}

variable "machine_type" {
  description = "Machine Type."
  default = "n1-standard-1"
}

variable "operating_system" {
  description = "Operating System."
  default = "ubuntu-os-cloud/ubuntu-1804-lts"
}
