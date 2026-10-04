# Product-wide settings, read by root.hcl and by the _envcommon files.
#
# Why a separate file? A file read with read_terragrunt_config() resolves
# find_in_parent_folders() from its OWN directory, so the _envcommon files
# cannot read root.hcl (it looks for account.hcl, env.hcl... above itself).
# This file has no lookups, so anyone can read it.
locals {
  product     = "learning-terraform"
  prefix      = "lt" # short product name, the start of every resource name
  team        = "platform-engineering"
  repository  = "github.com/aeciopires/terraform"
  cost_center = "learning"
}
