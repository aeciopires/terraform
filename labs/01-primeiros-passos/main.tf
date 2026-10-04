# Lab 01: Terraform/OpenTofu basics without any cloud. Every block type a
# beginner meets first: variable, locals, resource, count, for_each,
# a function call, a template file and output.

locals {
  # Computed once, used in several places.
  output_dir = "${path.module}/output/${var.environment}"
  common_header = {
    environment = var.environment
    team        = var.team
  }
}

# for_each: one random name per entry of var.pets, addressed by the key
# (random_pet.this["cat"], random_pet.this["dog"]).
resource "random_pet" "this" {
  for_each = var.pets

  length    = each.value
  separator = "-"
}

# One file per pet; depends on random_pet implicitly (it reads its id).
resource "local_file" "pet" {
  for_each = var.pets

  filename        = "${local.output_dir}/${each.key}.txt"
  file_permission = "0644"
  content = templatefile("${path.module}/templates/pet.txt.tftpl", {
    header = local.common_header
    kind   = each.key
    name   = random_pet.this[each.key].id
  })
}

# count: 0 or 1 copy - the usual way to make a resource optional.
resource "local_file" "readme" {
  count = var.create_readme ? 1 : 0

  filename        = "${local.output_dir}/README.txt"
  file_permission = "0644"
  content         = "Files created by Terraform/OpenTofu for ${var.environment}. Pets: ${join(", ", sort(keys(var.pets)))}.\n"
}
