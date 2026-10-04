# Settings of the "dev" environment in this project.
locals {
  environment = "dev"

  # Google recommends one project per environment. To do that, set the
  # environment's own project here (and its number), e.g.:
  # project_id     = "my-company-dev"
  # project_number = "123456789012"

  # Sizes that change between environments.
  run_max_instances = 2
  sql_tier          = "db-custom-1-3840"
}
