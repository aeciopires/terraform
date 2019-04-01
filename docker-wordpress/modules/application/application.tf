# Font:
# http://blog.aeciopires.com/instalando-o-wordpress-via-docker/
# https://hub.docker.com/_/wordpress/
# https://hub.docker.com/_/mysql/

#------------------------------------------------
# Install Docker-CE locally
resource "null_resource" "install_docker" {
  provisioner "local-exec" {
    working_dir = "/tmp",
    command     = <<EOT
      if ! ``docker --version > /dev/null 2>&1`` ; then 
        sudo curl -sSL https://get.docker.com/ | sh;
        sudo usermod -aG docker `echo $USER`;
        sudo setfacl -m user:`echo $USER`:rw /var/run/docker.sock
      fi
   EOT
  }
}

#------------------------------------------------
# Create a container MySQL
resource "docker_container" "container1" {
  depends_on = [
    "docker_image.image1" 
  ],
  name       = "mysql-wordpress"
  hostname   = "mysql-wordpress"
  image      = "${docker_image.image1.name}"
  dns        = "${var.dns_address}"
  dns_search = "${var.dns_domain_search}"
  restart    = "always"
  memory     = "${var.container_memory}"
  env        = ["MYSQL_USER=${var.database_user}",
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
  depends_on = [
    "null_resource.install_docker"
  ],
  name         = "mysql:5.7"
  keep_locally = true
}

#------------------------------------------------
# Create a container Wordpress
resource "docker_container" "container2" {
  depends_on = [
    "docker_container.container1",
    "docker_image.image2" 
  ],
  name       = "wordpress"
  hostname   = "wordpress"
  image      = "${docker_image.image2.name}"
  dns        = "${var.dns_address}"
  dns_search = "${var.dns_domain_search}"
  restart    = "always"
  memory     = "${var.container_memory}"
  env        = ["WORDPRESS_DB_USER=${var.database_user}",
                "WORDPRESS_DB_PASSWORD=${var.database_password}",
                "WORDPRESS_DB_DATABASE=${var.database_name}",
                "WORDPRESS_DB_HOST=${var.database_address}"]
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

# Pull image Wordpress
resource "docker_image" "image2" {
  name         = "wordpress:latest"
  keep_locally = true
}
