# Settings of region us-west-2 for this account and environment.
locals {
  region   = "us-west-2"
  vpc_cidr = "10.20.0.0/16"
  # Explicit Availability Zones: a plan never changes because AWS added or
  # hid a zone. Check them with: aws ec2 describe-availability-zones
  azs = ["us-west-2a", "us-west-2b"]
}
