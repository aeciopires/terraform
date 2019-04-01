#-------------------------
# Changes the values default of accord with the necessity
#-------------------------

variable "aws_zone" {
  description = "The zone to operate under, if not specified by a given resource."
  default = "us-east-2"
}

variable "aws_key_name" {
  description = "Key name."
  default     = "your_aws_name"
}

variable "aws_connection_type" {
  description = "Connection type."
  default     = "ssh"
}

variable "aws_key_path" {
  description = "Private Key path."
  default     = "your_aws_path"
}

variable "aws_instance_user" {
  description = "Instance user for remote connection."
  default     = "ubuntu"
}

variable "machine_type" {
  description = "Machine Type."
  default     = "t2.medium"
}

# Default: Ubuntu 16.04
variable "operating_system" {
  description = "Operating System."
  default     = "ami-0552e3455b9bc8d50"
}

variable "secret_key_database" {
  description = "Secret Key Database Openproject."
  default     = "secret"
}

variable "dir_host_path_pgdata" {
  description = "Path of directory of Docker Host to files storage of container. If not exists, will creat by terraform."
  default     = "/docker/openproject/pgdata"
}

variable "dir_host_path_logs" {
  description = "Path of directory of Docker Host to files storage of container. If not exists, will creat by terraform."
  default     = "/docker/openproject/logs"
}

variable "dir_host_path_static" {
  description = "Path of directory of Docker Host to files storage of container. If not exists, will creat by terraform."
  default     = "/docker/openproject/static"
}

variable "permission_read_only" {
  description = "Access permission in directory of Docker Host. If false, read and write. If true, read only."
  default     = false
}

variable "port_ssh_external" {
  description = "Port SSH external."
  default     = 22
}

variable "port_http_external" {
  description = "Port HTTP external."
  default     = 80
}

variable "port_https_external" {
  description = "Port HTTPS external."
  default     = 443
}
