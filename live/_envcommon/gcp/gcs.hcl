# Common configuration of the "gcs" unit: several Cloud Storage buckets from
# ONE unit - the public module loops over "names" itself.
#
# Module: https://registry.terraform.io/modules/terraform-google-modules/cloud-storage/google/12.4.0
locals {
  common  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  environment = local.env.locals.environment
  is_floci    = local.account.locals.target == "floci"
  project_id  = try(local.env.locals.project_id, local.account.locals.project_id)

  # The buckets every environment gets. A unit may pass its own "names".
  bucket_names = ["assets", "logs"]
}

terraform {
  source = "tfr:///terraform-google-modules/cloud-storage/google?version=12.4.0"
}

inputs = {
  project_id = local.project_id
  location   = "US"
  names      = local.bucket_names

  # Applied to every bucket of the unit's "names" (maps are keyed by name).
  # Uniform bucket-level access: IAM only, no per-object ACLs. floci-gcp
  # 0.9.0 does not keep this setting, so it is off there (otherwise every
  # plan shows a change) - see docs/04-providers-e-floci.md.
  bucket_policy_only       = { for n in local.bucket_names : n => !local.is_floci }
  force_destroy            = { for n in local.bucket_names : n => local.environment != "prd" }
  versioning               = { assets = true, logs = false }
  public_access_prevention = "enforced"
}
