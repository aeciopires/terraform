# Font:
# http://blog.aeciopires.com/zabbix-docker/
# https://hub.docker.com/r/zabbix
# https://hub.docker.com/_/mysql/

#------------------------------------------------
# Install Docker-CE locally
resource "null_resource" "install_docker" {
  provisioner "local-exec" {
    working_dir = "/tmp",
    command     = <<EOT
      sudo curl -sSL https://get.docker.com/ | sh;
      sudo usermod -aG docker `echo $USER`;
      sudo setfacl -m user:`echo $USER`:rw /var/run/docker.sock
   EOT
  }
}

#------------------------------------------------
# Create a container MySQL
resource "docker_container" "container1" {
  depends_on = [
    "docker_image.image1" 
  ],
  name       = "mysql-zabbix"
  hostname   = "mysql-zabbix"
  image      = "${docker_image.image1.name}"
  dns        = "${var.dns_address}"
  dns_search = "${var.dns_domain_search}"
  restart    = "always"
  memory     = "${var.container_memory}"
  env        = [
    "MYSQL_HOST=${var.database_address}",
    "MYSQL_USER=${var.database_user}",
    "MYSQL_PASSWORD=${var.database_password}",
    "MYSQL_DATABASE=${var.database_name}",
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}"
  ]
  ports {
    external = "${var.port_mysql_external}"
    internal = 3306
    protocol = "${var.port_protocol}"
  }
  volumes {
    host_path      = "${var.dir_host_path}"
    container_path = "/var/lib/mysql"
    read_only      = "${var.permission_read_only}"
  }
}

# Pull image MySQL
resource "docker_image" "image1" {
  depends_on = [
    "null_resource.install_docker"
  ],
  name         = "mysql:5.7"
  keep_locally = true
}

#------------------------------------------------
# Create a container Zabbix Server
resource "docker_container" "container2" {
  depends_on = [
    "docker_container.container1",
    "docker_image.image2"
  ],
  name       = "zabbix-server"
  hostname   = "zabbix-server"
  image      = "${docker_image.image2.name}"
  dns        = "${var.dns_address}"
  dns_search = "${var.dns_domain_search}"
  restart    = "always"
  memory     = "${var.container_memory}"
  env        = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
    "MYSQL_USER=${var.database_user}",
    "MYSQL_PASSWORD=${var.database_password}",
    "MYSQL_DATABASE=${var.database_name}",
    "DB_SERVER_PORT=${var.port_mysql_external}",
    "DB_SERVER_HOST=${var.database_address}"
  ]
  ports {
    external = "${var.port_zabbix_server}"
    internal = 10051
    protocol = "${var.port_protocol}"
  }
}

# Pull image Zabbix Server
resource "docker_image" "image2" {
  name         = "zabbix/zabbix-server-mysql:ubuntu-${var.version_zabbix}-latest"
  keep_locally = true
}

#------------------------------------------------
# Create a container Zabbix Web
resource "docker_container" "container3" {
  depends_on = [
    "docker_container.container1",
    "docker_image.image3"
  ],
  name       = "zabbix-web"
  hostname   = "zabbix-web"
  image      = "${docker_image.image3.name}"
  dns        = "${var.dns_address}"
  dns_search = "${var.dns_domain_search}"
  restart    = "always"
  memory     = "${var.container_memory}"
  env        = [
    "PHP_TZ=America/Sao_Paulo",
    "ZBX_SERVER_HOST=${var.zabbix_address}",
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
    "MYSQL_USER=${var.database_user}",
    "MYSQL_PASSWORD=${var.database_password}",
    "MYSQL_DATABASE=${var.database_name}",
    "DB_SERVER_PORT=${var.port_mysql_external}",
    "DB_SERVER_HOST=${var.database_address}"
  ]
  ports {
    external = "${var.port_http_external}"
    internal = 80
    protocol = "${var.port_protocol}"
  }
  ports {
    external = "${var.port_https_external}"
    internal = 443
    protocol = "${var.port_protocol}"
  }
}

# Pull image Zabbix Web
resource "docker_image" "image3" {
  name         = "zabbix/zabbix-web-apache-mysql:ubuntu-${var.version_zabbix}-latest"
  keep_locally = true
}

#------------------------------------------------
# Create a container Zabbix Agent
resource "docker_container" "container4" {
  depends_on = [
    "docker_container.container2",
    "docker_image.image4"
  ],
  name       = "zabbix-agent"
  hostname   = "${var.hostname_agent}"
  image      = "${docker_image.image4.name}"
  dns        = "${var.dns_address}"
  dns_search = "${var.dns_domain_search}"
  restart    = "always"
  #networks   = ["host"]
  privileged = true
  memory     = "${var.container_memory}"
  env        = [
    "ZBX_HOSTNAME=${var.hostname_agent}",
    "ZBX_SERVER_HOST=${var.zabbix_address}"
  ]
  ports {
    external = "${var.port_zabbix_agent}"
    internal = 10050
    protocol = "${var.port_protocol}"
  }
  volumes {
    host_path      = "/"
    container_path = "/rootfs"
    read_only      = "${var.permission_read_only}"
  }
  volumes {
    host_path      = "/var/run"
    container_path = "/var/run"
    read_only      = "${var.permission_read_only}"
  }
}

# Pull image Zabbix Agent
resource "docker_image" "image4" {
  name         = "zabbix/zabbix-agent:ubuntu-${var.version_zabbix}-latest"
  keep_locally = true
}

#------------------------------------------------
# Execute scripts of Zabbix API
resource "null_resource" "zabbix_api_ubuntu18" {
  depends_on = [
    "docker_container.container4",
  ],
  provisioner "local-exec" {
    command = <<EOT
      sudo apt install -y python3 python3-pip;
      pip3 install zabbix-api;
      "`pwd`/api-zabbix/create_groups.py ${var.home_user_work_dir}/credentials_zabbix_api.txt ${var.home_user_work_dir}/hostgroups.csv";
      "`pwd`/api-zabbix/create_hosts.py ${var.home_user_work_dir}/credentials_zabbix_api.txt ${var.home_user_work_dir}/hosts.csv";
   EOT
  }
}