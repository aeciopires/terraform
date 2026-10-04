# Unit tests of the wrapper: no cloud, no credentials (mock_provider).
# They live next to the wrapper, not in ../tests, because OpenTofu and
# Terraform load a root module's tests/ during init: a test that called
# ./wrappers from the module root would break whenever a tool (Terragrunt)
# generates a provider.tf in that root.
# Run from this directory: terraform init -backend=false && terraform test

mock_provider "google" {
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }
}

run "wrapper_loops_over_items" {
  command = apply

  variables {
    defaults = {
      project_id    = "unit-project"
      subscriptions = { worker = {} }
      labels        = { team = "platform" }
    }
    items = {
      audit  = {}
      emails = { subscriptions = { sender = { create_dead_letter = false } } }
    }
  }

  assert {
    condition     = keys(module.wrapper) == ["audit", "emails"]
    error_message = "The wrapper must create one instance per item."
  }

  assert {
    condition     = keys(module.wrapper["audit"].subscriptions) == ["worker"] && keys(module.wrapper["emails"].subscriptions) == ["sender"]
    error_message = "An item's subscriptions override the defaults."
  }

  assert {
    condition     = length(module.wrapper["emails"].dead_letter_topics) == 0
    error_message = "create_dead_letter = false must not create a dead-letter topic."
  }
}
