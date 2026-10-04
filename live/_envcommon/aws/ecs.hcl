# Common configuration of the "ecs" unit: an ECS cluster with one Fargate
# service running nginx (Docker Hub) behind the ALB.
#
# Module: https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/7.6.1
locals {
  # Settings from the directory hierarchy (see live/root.hcl). Found from
  # the unit's directory, because this file is included by the unit.
  common  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  environment = local.env.locals.environment
  name_prefix = "${local.common.locals.prefix}-${local.environment}"
  is_floci    = local.account.locals.target == "floci"

  # https://hub.docker.com/_/nginx - pin a tag, never "latest".
  image          = "nginx:1.29-alpine"
  container_port = 80
}

terraform {
  source = "tfr:///terraform-aws-modules/ecs/aws?version=7.6.1"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    private_subnets = ["subnet-00000003", "subnet-00000004"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "alb" {
  config_path = "../alb"

  mock_outputs = {
    security_group_id = "sg-00000000"
    target_groups     = { web = { arn = "arn:aws:elasticloadbalancing:us-east-1:000000000000:targetgroup/mock/0000000000000000" } }
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  cluster_name = "${local.name_prefix}-ecs"

  services = {
    web = {
      cpu           = 256
      memory        = 512
      desired_count = local.env.locals.app_desired_count

      container_definitions = {
        web = {
          image                  = local.image
          essential              = true
          readonlyRootFilesystem = false # nginx writes to /var/cache/nginx
          portMappings = [{
            name          = "http"
            containerPort = local.container_port
            protocol      = "tcp"
          }]
        }
      }

      load_balancer = {
        service = {
          target_group_arn = dependency.alb.outputs.target_groups["web"].arn
          container_name   = "web"
          container_port   = local.container_port
        }
      }

      subnet_ids = dependency.vpc.outputs.private_subnets

      # Only the ALB reaches the tasks.
      security_group_ingress_rules = {
        alb = {
          from_port                    = local.container_port
          ip_protocol                  = "tcp"
          referenced_security_group_id = dependency.alb.outputs.security_group_id
        }
      }
      security_group_egress_rules = {
        all = {
          ip_protocol = "-1"
          cidr_ipv4   = "0.0.0.0/0"
        }
      }
    }
  }
}
