# Unit tests of the wrapper: no cloud, no credentials (mock_provider).
# They live next to the wrapper, not in ../tests, because OpenTofu and
# Terraform load a root module's tests/ during init: a test that called
# ./wrappers from the module root would break whenever a tool (Terragrunt)
# generates a provider.tf in that root.
# Run from this directory: terraform init -backend=false && terraform test

mock_provider "aws" {
  # The IAM policy document data source must return valid JSON, because
  # aws_sqs_queue_policy validates it.
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  # ARNs are validated by the resources that receive them, so the random
  # strings the mock would generate are replaced by well-formed ones.
  mock_resource "aws_sns_topic" {
    defaults = {
      arn = "arn:aws:sns:us-east-1:123456789012:mock-topic"
    }
  }

  mock_resource "aws_sqs_queue" {
    defaults = {
      arn = "arn:aws:sqs:us-east-1:123456789012:mock-queue"
      url = "https://sqs.us-east-1.amazonaws.com/123456789012/mock-queue"
    }
  }
}

# The wrapper: one module call, many instances; defaults fill the gaps.
run "wrapper_loops_over_items" {
  command = apply

  variables {
    defaults = {
      queues = { worker = {} }
      tags   = { Team = "platform" }
    }
    items = {
      audit  = {}
      emails = { create_topic = false, tags = { Domain = "email" } }
    }
  }

  assert {
    condition     = keys(module.wrapper) == ["audit", "emails"]
    error_message = "The wrapper must create one instance per item."
  }

  assert {
    condition     = module.wrapper["audit"].topic_name == "audit" && module.wrapper["emails"].topic_arn == null
    error_message = "Item keys become names; create_topic from the item overrides the default."
  }

  assert {
    condition     = module.wrapper["emails"].queues["worker"].name == "emails-worker"
    error_message = "Queues from defaults must be created in every item."
  }
}
