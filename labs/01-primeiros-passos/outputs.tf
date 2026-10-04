output "pet_names" {
  description = "Random name of every pet."
  value       = { for k, p in random_pet.this : k => p.id }
}

output "files" {
  description = "Path of every file created."
  value       = concat([for f in local_file.pet : f.filename], local_file.readme[*].filename)
}
