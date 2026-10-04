# Unit "gcs": the buckets listed in _envcommon/gcp/gcs.hcl, with names made
# globally unique by the project ID.
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/gcp/gcs.hcl"
  expose         = true
  merge_strategy = "deep"
}

inputs = {
  # Bucket names are global: e.g. lt-dev-floci-local-assets.
  prefix = "${include.root.locals.name_prefix}-${include.root.locals.account_id}"
}
