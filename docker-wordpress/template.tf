#---------------------------------------------------------------
# Informations
# Tutorial: http://blog.aeciopires.com/conhecendo-o-terraform
# autor: Aecio Pires
# email: http://blog.aeciopires.com/contato
# version: 0.1.0
# description: Create Docker conteiner
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

# Configure the Docker provider
provider "docker" {
  host = "${var.docker_host_socket}"
  registry_auth {
    address  = "${var.docker_registry_address}"
    username = "${var.docker_registry_username}"
    password = "${var.docker_registry_password}"
  }
}

module "container" {
  source = "./modules/application"
}
