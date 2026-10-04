variable "environment" {
  description = "Environment name: dev, stg or prd."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "environment must be dev, stg or prd."
  }
}

variable "team" {
  description = "Team that owns the files."
  type        = string
  default     = "platform-engineering"
}

variable "pets" {
  description = "One file per pet: key = file name, value = number of words of its random name."
  type        = map(number)
  default = {
    cat = 2
    dog = 3
  }

  validation {
    condition     = alltrue([for n in values(var.pets) : n >= 1 && n <= 5])
    error_message = "Each pet name must have 1 to 5 words."
  }
}

variable "create_readme" {
  description = "Whether to create the README.txt file (shows a conditional resource)."
  type        = bool
  default     = true
}
