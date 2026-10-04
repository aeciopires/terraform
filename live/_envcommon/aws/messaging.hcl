# Common configuration of the "messaging" unit: several SNS+SQS fan-outs
# from ONE unit, through the wrapper of this repository's own module.
#
# The "//" separates the directory Terragrunt copies (the whole module, so
# the wrapper's `source = "../"` works) from the path inside it. In another
# repository, use a Git URL pinned to a tag:
#   git::https://github.com/aeciopires/terraform.git//modules/aws-messaging/wrappers?ref=<tag>
terraform {
  source = "${get_repo_root()}/modules/aws-messaging//wrappers"
}

inputs = {
  defaults = {
    queues = {
      worker = { max_receive_count = 5 }
    }
  }
}
