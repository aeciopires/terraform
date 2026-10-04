# Unit "s3": several buckets from one unit. The common settings
# (encryption, versioning, public access block) come from
# _envcommon/aws/s3.hcl as "defaults"; each item only says what differs.
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/aws/s3.hcl"
  expose         = true
  merge_strategy = "deep"
}

locals {
  # S3 bucket names are global: account ID and region make them unique.
  bucket_prefix = "${include.root.locals.name_prefix}-${include.root.locals.account_id}-${include.root.locals.region}"
}

inputs = {
  items = {
    # The loop: defaults only.
    assets = {
      bucket = "${local.bucket_prefix}-assets"
    }
    # Same loop, one value overridden.
    logs = {
      bucket     = "${local.bucket_prefix}-logs"
      versioning = { enabled = false }
      lifecycle_rule = [{
        id         = "expire-logs"
        enabled    = true
        filter     = {}
        expiration = { days = 30 }
      }]
    }
  }
}
