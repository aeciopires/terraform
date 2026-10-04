# Root Terragrunt configuration, included by every unit under live/.
#
# Directory layout (each level adds one file of settings):
#
#   live/<cloud>/<account>/<environment>/<region>/<unit>/terragrunt.hcl
#         cloud.hcl account.hcl  env.hcl      region.hcl
#
# - cloud:       aws | gcp (provider versions)
# - account:     an AWS account or a GCP project; target = "floci" (local
#                emulator) or "real" (a real, billed account/project)
# - environment: dev | stg | prd
# - region:      us-east-1, us-central1, ...
# - unit:        one piece of infrastructure = one module call = one state
#
# What this file provides to every unit, so units stay a few lines long:
# 1. locals with every setting from the files above (name prefix, labels...)
# 2. remote_state: S3 (AWS) or GCS (GCP) backend, one state file per unit
# 3. generate "provider"/"versions": provider configuration and pinned
#    provider versions, written next to the module code
# 4. extra_arguments: on floci, the endpoint variables that point the
#    providers at the emulators; on a real account, variables that make sure
#    no emulator endpoint left in your shell is used
#
# References (Terragrunt 1.1.6):
# - https://docs.terragrunt.com/features/units/includes/
# - https://docs.terragrunt.com/features/units/state-backend/
# - https://docs.terragrunt.com/reference/hcl/blocks/
# - https://docs.terragrunt.com/reference/hcl/functions/

locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  cloud_vars   = read_terragrunt_config(find_in_parent_folders("cloud.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # --- product-wide settings (common.hcl) ---------------------------------
  product     = local.common_vars.locals.product
  prefix      = local.common_vars.locals.prefix
  team        = local.common_vars.locals.team
  repository  = local.common_vars.locals.repository
  cost_center = local.common_vars.locals.cost_center

  # --- settings from the directory hierarchy -----------------------------
  cloud        = local.cloud_vars.locals.cloud
  target       = local.account_vars.locals.target
  is_floci     = local.target == "floci"
  account_name = local.account_vars.locals.account_name
  environment  = local.env_vars.locals.environment
  region       = local.region_vars.locals.region

  # AWS: the 12-digit account ID. GCP: the project ID - an environment may
  # use its own project (env.hcl project_id), as GCP recommends.
  account_id = local.cloud == "aws" ? local.account_vars.locals.account_id : try(local.env_vars.locals.project_id, local.account_vars.locals.project_id)

  # "<prefix>-<environment>", e.g. "lt-dev": the start of every name.
  name_prefix = "${local.prefix}-${local.environment}"

  # Tags (AWS) and labels (GCP) on every resource. GCP label keys and
  # values only accept lower-case letters, digits, "_" and "-".
  tags = {
    Product     = local.product
    Environment = local.environment
    Team        = local.team
    CostCenter  = local.cost_center
    ManagedBy   = "terragrunt"
    Repository  = local.repository
    Unit        = path_relative_to_include()
  }
  labels = {
    product     = local.product
    environment = local.environment
    team        = local.team
    cost-center = local.cost_center
    managed-by  = "terragrunt"
    unit        = replace(lower(basename(get_terragrunt_dir())), "/[^a-z0-9_-]/", "-")
  }

  # --- emulator endpoints (floci) ----------------------------------------
  floci_aws_endpoint = get_env("FLOCI_AWS_ENDPOINT", "http://localhost.floci.io:4566")
  floci_gcp_endpoint = get_env("FLOCI_GCP_ENDPOINT", "http://localhost:4588")

  # The Google provider reads one GOOGLE_<PRODUCT>_CUSTOM_ENDPOINT variable
  # per API (see the provider's google/services/<product>/product.go).
  gcp_endpoint_paths = {
    GOOGLE_STORAGE_CUSTOM_ENDPOINT          = "/storage/v1/"
    GOOGLE_PUBSUB_CUSTOM_ENDPOINT           = "/v1/"
    GOOGLE_IAM_BETA_CUSTOM_ENDPOINT         = "/v1/"
    GOOGLE_RESOURCE_MANAGER_CUSTOM_ENDPOINT = "/v1/"
    GOOGLE_SERVICE_USAGE_CUSTOM_ENDPOINT    = "/v1/"
    GOOGLE_CLOUD_RUN_V2_CUSTOM_ENDPOINT     = "/v2/"
    GOOGLE_SQL_CUSTOM_ENDPOINT              = "/sql/v1beta4/"
    GOOGLE_SECRET_MANAGER_CUSTOM_ENDPOINT   = "/v1/"
    GOOGLE_KMS_CUSTOM_ENDPOINT              = "/v1/"
    # floci-gcp 0.9.0 has no Compute Engine API; pointing it at the emulator
    # anyway guarantees no call ever reaches the real Google Cloud.
    GOOGLE_COMPUTE_CUSTOM_ENDPOINT = "/compute/v1/"
  }

  env_by_target = {
    aws = {
      floci = {
        AWS_ENDPOINT_URL      = local.floci_aws_endpoint
        AWS_ACCESS_KEY_ID     = "test"
        AWS_SECRET_ACCESS_KEY = "test"
        AWS_REGION            = local.region
      }
      # Ignore AWS_ENDPOINT_URL* left in your shell from a floci session.
      real = {
        AWS_IGNORE_CONFIGURED_ENDPOINT_URLS = "true"
      }
    }
    gcp = {
      floci = merge(
        { for k, path in local.gcp_endpoint_paths : k => "${local.floci_gcp_endpoint}${path}" },
        # floci-gcp accepts any token; the provider only needs one to exist.
        { GOOGLE_OAUTH_ACCESS_TOKEN = "floci-fake-token" }
      )
      # An empty value makes the provider use the default Google endpoints.
      real = { for k, path in local.gcp_endpoint_paths : k => "" }
    }
  }
  tf_env = local.env_by_target[local.cloud][local.target]

  # --- state backend --------------------------------------------------------
  # One bucket per account/project; one state file per unit, keyed by the
  # unit's path, e.g. aws/floci-sandbox/dev/us-east-1/vpc/tf.tfstate.
  state_bucket = "${local.prefix}-tfstate-${local.account_id}"

  # Extra backend settings per target. (An object indexed by the target,
  # because "cond ? {...} : {}" fails when the two objects differ.)
  s3_backend_by_target = {
    floci = {
      endpoints                   = { s3 = local.floci_aws_endpoint, sts = local.floci_aws_endpoint }
      access_key                  = "test"
      secret_key                  = "test"
      skip_credentials_validation = true
      skip_requesting_account_id  = true
      # Bucket features floci does not need for local state.
      skip_bucket_ssencryption = true
      skip_bucket_root_access  = true
      skip_bucket_enforced_tls = true
    }
    real = {}
  }

  s3_backend = merge(
    {
      bucket       = local.state_bucket
      key          = "${path_relative_to_include()}/tf.tfstate"
      region       = try(local.account_vars.locals.state_region, null)
      encrypt      = true
      use_lockfile = true # native S3 locking (Terraform/OpenTofu >= 1.10)
    },
    local.s3_backend_by_target[local.target]
  )

  gcs_backend = merge(
    {
      bucket   = local.state_bucket
      prefix   = path_relative_to_include()
      project  = local.account_id
      location = try(local.account_vars.locals.state_location, null)
    },
    # Terragrunt's own GCS client cannot reach floci-gcp: on floci it must not
    # create the bucket (and `--backend-bootstrap` must not be used - with it,
    # Terragrunt 1.1.6 tried to create the bucket on the real Google Cloud).
    # `make floci-bootstrap` creates it with the emulator's REST API instead.
    # Terraform/OpenTofu reach floci-gcp through GOOGLE_STORAGE_CUSTOM_ENDPOINT
    # (extra_arguments below).
    { floci = { skip_bucket_creation = true }, real = {} }[local.target]
  )

  # --- provider configuration -------------------------------------------------
  # cloud.hcl versions, with the unit's exceptions (if any) on top.
  provider_versions = merge(
    local.cloud_vars.locals.provider_versions,
    try(local.cloud_vars.locals.provider_version_overrides[basename(get_terragrunt_dir())], {})
  )

  aws_provider = <<-EOF
    provider "aws" {
      region = "${local.region}"

      # Refuses to run against any other account - a guard against applying
      # with the wrong credentials (floci always answers 000000000000).
      allowed_account_ids = ["${local.account_id}"]

      default_tags {
        tags = ${jsonencode(local.tags)}
      }
    }
  EOF

  gcp_provider = <<-EOF
    provider "google" {
      project        = "${local.account_id}"
      region         = "${local.region}"
      default_labels = ${jsonencode(local.labels)}
    }

    provider "google-beta" {
      project        = "${local.account_id}"
      region         = "${local.region}"
      default_labels = ${jsonencode(local.labels)}
    }
  EOF

  required_providers = {
    aws = {
      aws = { source = "hashicorp/aws", version = try(local.provider_versions.aws, null) }
    }
    gcp = {
      google      = { source = "hashicorp/google", version = try(local.provider_versions.google, null) }
      google-beta = { source = "hashicorp/google-beta", version = try(local.provider_versions.google-beta, null) }
    }
  }
}

remote_state {
  backend = { aws = "s3", gcp = "gcs" }[local.cloud]
  config  = { aws = local.s3_backend, gcp = local.gcs_backend }[local.cloud]

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = local.cloud == "aws" ? local.aws_provider : local.gcp_provider
}

# Pins the exact provider versions of the whole cloud (cloud.hcl). The
# module already has a versions.tf, so this is an *override file*: its
# required_providers entries replace the module's constraint for the same
# provider; everything else in the module's terraform block is kept.
# https://developer.hashicorp.com/terraform/language/files/override
# A unit whose module needs other versions is listed in
# provider_version_overrides of cloud.hcl (see live/gcp/cloud.hcl).
generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
%{for name, p in local.required_providers[local.cloud]~}
    ${name} = {
      source  = "${p.source}"
      version = "${p.version}"
    }
%{endfor~}
  }
}
EOF
}

terraform {
  extra_arguments "cloud_endpoints" {
    commands = concat(get_terraform_commands_that_need_vars(), ["init", "output", "show", "state", "providers", "validate", "test", "force-unlock"])
    env_vars = local.tf_env
  }
}

# No "inputs" here on purpose. Terragrunt passes every input to every
# module as TF_VAR_<name>; a module that happens to declare a variable with
# that name receives it. A global "name_prefix" input, for example, reached
# the ALB module's own name_prefix variable and broke it ("name conflicts
# with name_prefix"). Units take what they need from include.root.locals.
