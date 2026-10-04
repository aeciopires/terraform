# Settings of region us-east-1 for this account and environment.
locals {
  region   = "us-east-1"
  vpc_cidr = "10.10.0.0/16"
  # Explicit Availability Zones: a plan never changes because AWS added or
  # hid a zone. Check them with: aws ec2 describe-availability-zones
  azs = ["us-east-1a", "us-east-1b"]
}
