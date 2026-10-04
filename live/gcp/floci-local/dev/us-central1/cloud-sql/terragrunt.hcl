# Unit "cloud-sql": everything this environment needs is in the common file;
# add an "inputs" block here only to override a value for this unit.
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/gcp/cloud-sql.hcl"
  expose         = true
  merge_strategy = "deep"
}
