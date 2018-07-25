#-------------------------
# Changes the values default of accord with the necessity
#-------------------------

variable "docker_host_socket" {
  description = "Socket to the process or address remote of the Docker Host."
  default = "unix:///var/run/docker.sock"
}

variable "docker_registry_address" {
  description = "Address to Docker Registry or Docker Hub."
  default = "registry.domain.com.br:443"
}

variable "docker_registry_username" {
  description = "Account in Docker Registry or Docker Hub to access private images."
  default = "login"
}

variable "docker_registry_password" {
  description = "Password of the account in Docker Registry or Docker Hub to access private images."
  default = "pass"
}
