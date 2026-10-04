provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Product     = "learning-terraform"
      Environment = var.environment
      ManagedBy   = "terraform"
      Lab         = "04-modulos"
    }
  }
}
