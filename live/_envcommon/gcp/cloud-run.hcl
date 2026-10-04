# Common configuration of the "cloud-run" unit: a public Cloud Run service
# running nginx from Docker Hub.
#
# Module: https://registry.terraform.io/modules/GoogleCloudPlatform/cloud-run/google/0.34.1
locals {
  common  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment = local.env.locals.environment
  name_prefix = "${local.common.locals.prefix}-${local.environment}"
  project_id  = try(local.env.locals.project_id, local.account.locals.project_id)

  # https://hub.docker.com/_/nginx - pin a tag, never "latest".
  image = "nginx:1.29-alpine"
}

terraform {
  source = "tfr:///GoogleCloudPlatform/cloud-run/google//modules/v2?version=0.34.1"
}

# This module (0.34.1) requires google/google-beta < 8: the provider
# versions for this unit come from provider_version_overrides in
# live/gcp/cloud.hcl.

inputs = {
  project_id   = local.project_id
  location     = local.region.locals.region
  service_name = "${local.name_prefix}-web"

  # Allow deleting the service with `destroy` outside production.
  cloud_run_deletion_protection = local.environment == "prd"

  # Public service: anyone may invoke it.
  members = ["allUsers"]

  template_scaling = {
    min_instance_count = 0
    max_instance_count = local.env.locals.run_max_instances
  }

  containers = [{
    container_image = local.image
    ports           = { container_port = 80 }
    resources = {
      limits = { cpu = "1", memory = "256Mi" }
    }
  }]
}
