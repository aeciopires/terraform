#---------------------------------------------------------------
# Informations
# Tutorial: http://blog.aeciopires.com/conhecendo-o-terraform
# autor: Aecio Pires
# email: http://blog.aeciopires.com/contato
# version: 0.1.0
# description: Create Instances in Amazon AWS
#---------------------------------------------------------------
#
# Useful commands:
#
# terraform --help    => Show help of command terraform
# terraform providers => Prints a tree of the providers used in the configuration
# terraform init      => Initialize a Terraform working directory
# terraform validate  => Validates the Terraform files
# terraform plan      => Generate and show an execution plan
# terraform apply     => Builds or changes infrastructure
# terraform show      => Inspect Terraform state or plan
# terraform destroy   => Destroy Terraform-managed infrastructure
# terraform graph | dot -Tpng > graph.png => Create a visual graph of Terraform resources
#---------------------------------------------------------------


#----------------------------
# MAIN
#----------------------------

# The values of variables are defined in files 'variables.tf' and
# 'modules/application/variables.tf'

# Configure the AWS Cloud provider
provider "aws" {
  region = "${var.aws_zone}"
}

module "instances" {
  source               = "./modules/application"
  aws_zone             = "${var.aws_zone}"
  aws_key_name         = "${var.aws_key_name}"
  aws_connection_type  = "${var.aws_connection_type}"
  aws_key_path         = "${var.aws_key_path}"
  aws_instance_user    = "${var.aws_instance_user}"
  machine_type         = "${var.machine_type}"
  operating_system     = "${var.operating_system}"
  secret_key_database  = "${var.secret_key_database}"
  dir_host_path_pgdata = "${var.dir_host_path_pgdata}"
  dir_host_path_logs   = "${var.dir_host_path_logs}"
  dir_host_path_static = "${var.dir_host_path_static}"
  permission_read_only = "${var.permission_read_only}"
  port_ssh_external    = "${var.port_ssh_external}"
  port_http_external   = "${var.port_http_external}"
  port_https_external  = "${var.port_https_external}"
}
