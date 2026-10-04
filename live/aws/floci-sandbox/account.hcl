# An AWS "account" served by floci, the local AWS emulator: free, no
# credentials. floci always reports the account ID 000000000000.
#
# To use a real AWS account, copy this directory to live/aws/<account-name>,
# set target = "real", the real 12-digit account_id and a state_region, and
# authenticate as usual (AWS_PROFILE, SSO, ...). See docs/06-terragrunt.md.
locals {
  account_name = "floci-sandbox"
  account_id   = "000000000000"
  target       = "floci" # floci | real
  state_region = "us-east-1"
}
