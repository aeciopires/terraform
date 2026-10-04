# Tests of lab 01. The local and random providers need no cloud, so these
# tests use the real providers; "command = plan" creates nothing, while
# "command = apply" really writes the files and removes them at the end.
# Run: terraform test   (or: tofu test)

run "default_values_plan_two_pets_and_a_readme" {
  command = plan

  assert {
    condition     = length(local_file.pet) == 2 && length(local_file.readme) == 1
    error_message = "Expected one file per default pet plus the README."
  }

  assert {
    condition     = local_file.pet["cat"].filename == "./output/dev/cat.txt"
    error_message = "Files must go to output/<environment>/<pet>.txt."
  }
}

run "create_readme_false_skips_the_readme" {
  command = plan

  variables {
    create_readme = false
  }

  assert {
    condition     = length(local_file.readme) == 0
    error_message = "count = 0 must not create the README."
  }
}

run "apply_writes_the_files" {
  command = apply

  variables {
    environment = "stg"
    pets        = { owl = 1 }
  }

  assert {
    condition     = length(split("-", output.pet_names["owl"])) == 1
    error_message = "A 1-word pet name has no separator."
  }

  assert {
    condition     = strcontains(local_file.pet["owl"].content, "environment: stg")
    error_message = "The template must render the header."
  }
}

run "rejects_an_unknown_environment" {
  command = plan

  variables {
    environment = "production"
  }

  expect_failures = [var.environment]
}

run "rejects_too_many_words" {
  command = plan

  variables {
    pets = { snake = 9 }
  }

  expect_failures = [var.pets]
}
