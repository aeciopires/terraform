# Settings of the "stg" environment in this account.
locals {
  environment = "stg"

  # Sizes that change between environments.
  app_desired_count = 2
  db_instance_class = "db.t4g.small"

  # floci binds every load balancer listener on its own container, so each
  # ALB needs a port no other listener uses (published by docker-compose.yml).
  # On real AWS the ALB listens on 80 and this value is ignored.
  floci_alb_port = 8081
}
