#---------------------------------------------------------------
# Informations
# Tutorial: http://blog.aeciopires.com/conhecendo-o-terraform
# autor: Aecio Pires
# email: http://blog.aeciopires.com/contato
# version: 0.1.0
# description: Create Instances in Google Cloud
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

# Contents of a file that contains your service account private key in JSON format.
# You can download your existing Google Cloud service account file from the
# Google Cloud Console (https://console.cloud.google.com/apis/credentials/serviceaccountkey),
# or you can create a new one from the same page."

# Configure the Google Cloud provider
provider "google" {
  credentials = "${file("/home/aecio/account.json")}"
  project     = "${var.gc_project}"
  zone        = "${var.gc_zone}"
}

module "instances" {
  source = "./modules/application"
}
