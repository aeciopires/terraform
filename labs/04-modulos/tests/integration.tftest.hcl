# Integration test: applies the four module calls on floci (or AWS),
# checks what the APIs returned and destroys everything at the end.
# Run (floci): set -a; source ../../.env; set +a
#              terraform test

variables {
  environment = "dev"
}

run "every_module_call_works" {
  command = apply

  assert {
    condition     = endswith(output.logs_bucket, "-lab04-logs")
    error_message = "The public module must create the logs bucket."
  }

  assert {
    condition     = keys(output.app_buckets) == ["assets", "uploads"]
    error_message = "for_each must create one bucket per entry."
  }

  assert {
    condition     = output.messaging["lt-dev-lab04-emails"].topic_arn == null && output.messaging["lt-dev-lab04-audit"].topic_arn != null
    error_message = "Items override the wrapper defaults."
  }

  assert {
    condition     = startswith(output.orders_topic_arn, "arn:aws:sns:")
    error_message = "The custom module must create the orders topic."
  }
}
