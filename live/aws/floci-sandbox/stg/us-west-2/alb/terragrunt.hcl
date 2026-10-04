# Unit "alb": everything this environment needs is in the common file;
# add an "inputs" block here only to override a value for this unit.
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/aws/alb.hcl"
  expose         = true
  merge_strategy = "deep"
}
