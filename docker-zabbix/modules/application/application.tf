# Font:
# http://blog.aeciopires.com/zabbix-docker/
# https://hub.docker.com/r/zabbix
# https://hub.docker.com/_/mysql/

#------------------------------------------------
# Create a container MySQL
resource "docker_container" "container1" {
  depends_on = [
    "docker_image.image1" ],
  name       = "mysql-zabbix"
  hostname   = "mysql-zabbix"
  image      = "${docker_image.image1.name}"
  dns        = "${var.dns_address}"
  dns_search = "${var.dns_domain_search}"
  restart    = "always"
  memory     = "${var.container_memory}"
  env        = ["MYSQL_HOST=${var.database_address}",
                "MYSQL_USER=${var.database_user}",
                "MYSQL_PASSWORD=${var.database_password}",
                "MYSQL_DATABASE=${var.database_name}",
                "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}"]
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
  name         = "mysql:5.7"
  keep_locally = true
}

#------------------------------------------------
# Create a container Zabbix Server
resource "docker_container" "container2" {
  depends_on = [
    "docker_container.container1",
    "docker_image.image2" ],
  name       = "zabbix-server"
  hostname   = "zabbix-server"
  image      = "${docker_image.image2.name}"
  dns        = "${var.dns_address}"
  dns_search = "${var.dns_domain_search}"
  restart    = "always"
  memory     = "${var.container_memory}"
  env        = ["MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
                "MYSQL_USER=${var.database_user}",
                "MYSQL_PASSWORD=${var.database_password}",
                "MYSQL_DATABASE=${var.database_name}",
                "DB_SERVER_PORT=${var.port_mysql_external}",
                "DB_SERVER_HOST=${var.database_address}"]
  ports {
    external = "${var.port_zabbix_server}"
    internal = "${var.port_zabbix_server}"
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
    "docker_image.image3" ],
  name       = "zabbix-web"
  hostname   = "zabbix-web"
  image      = "${docker_image.image3.name}"
  dns        = "${var.dns_address}"
  dns_search = "${var.dns_domain_search}"
  restart    = "always"
  memory     = "${var.container_memory}"
  env        = ["PHP_TZ=America/Sao_Paulo",
                "ZBX_SERVER_HOST=${var.zabbix_address}",
                "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
                "MYSQL_USER=${var.database_user}",
                "MYSQL_PASSWORD=${var.database_password}",
                "MYSQL_DATABASE=${var.database_name}",
                "DB_SERVER_PORT=${var.port_mysql_external}",
                "DB_SERVER_HOST=${var.database_address}"]
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
    "docker_image.image4" ],
  name       = "zabbix-agent"
  hostname   = "${var.hostname_agent}"
  image      = "${docker_image.image4.name}"
  dns        = "${var.dns_address}"
  dns_search = "${var.dns_domain_search}"
  restart    = "always"
  #networks   = ["host"]
  privileged = true
  memory     = "${var.container_memory}"
  env        = ["ZBX_HOSTNAME=${var.hostname_agent}",
                "ZBX_SERVER_HOST=${var.zabbix_address}"]
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

resource "null_resource" "saltstack_provisioning" {
  depends_on = [
    "docker_container.container2",
    "docker_container.container3",
    "docker_container.container4" ],

  #provisioner "salt-masterless" {
  #  local_state_tree    = "salt"
  #  remote_state_tree   = "/srv/salt"
  #  local_pillar_roots  = "pillar"
  #  remote_pillar_roots = "/srv/pillar"
  #}

  # Install and configure salt-minion
  # Only ubuntu add command bellow
  # wget -O - https://repo.saltstack.com/apt/ubuntu/18.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
  provisioner "local-exec" {
    command = "pwd; sudo salt '*' state.apply;"
    #command = "cd /tmp; \
    #  curl -L https://bootstrap.saltstack.com -o install_salt.sh; \
    #  sudo sh install_salt.sh -P -M; \\
    #  sudo salt '*' state.apply"
  }
}
