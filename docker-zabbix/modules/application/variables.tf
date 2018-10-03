#-------------------------
# Changes the values default of accord with the necessity
#-------------------------

variable "database_user" {
  description = "Database user."
  default = "zabbix"
}

variable "database_password" {
  description = "Database password."
  default = "zabbix"
}

variable "database_name" {
  description = "Database name."
  default = "zabbix"
}

variable "database_address" {
  description = "Database address."
  default = "172.17.0.1"
}

variable "zabbix_address" {
  description = "Zabbix address."
  default = "172.17.0.1"
}

variable "mysql_root_password" {
  description = "Password of user root mysql."
  default = "secret"
}

variable "dns_address" {
  description = "List of IP address DNS servers."
  default = ["8.8.8.8"]
}

variable "dns_domain_search" {
  description = "List of DNS domain name search."
  default = ["domain.com.br"]
}

variable "container_memory" {
  description = "Limit max in MB of memory of containers."
  default = 512
}

variable "port_mysql_external" {
  description = "Port HTTP external of container."
  default = 3306
}

variable "version_zabbix" {
  description = "Version of Zabbix."
  default = "4.0"
}

variable "hostname_agent" {
  description = "Hostname of Zabbix Agent."
  default = "pires"
}

variable "port_zabbix_agent" {
  description = "Port external of container."
  default = 10050
}

variable "port_zabbix_server" {
  description = "Port external of container."
  default = 10051
}

variable "port_http_external" {
  description = "Port HTTP external of container."
  default = 80
}

variable "port_https_external" {
  description = "Port HTTPS external of container."
  default = 443
}

variable "port_protocol" {
  description = "Protocol of container ports."
  default = "TCP"
}

variable "dir_host_path" {
  description = "Path of directory of Docker Host to files storage of container. If not exists, will creat by terraform."
  default = "/docker/mysql/zabbix/data"
}

variable "permission_read_only" {
  description = "Access permission in directory of Docker Host. If false, read and write. If true, read only."
  default = false
}
