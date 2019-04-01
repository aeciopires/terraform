#-------------------------
# Override the values default
#-------------------------

# Português:
# Veja o arquivo `variables.tf` para obter a descrição de uso e os valores padrão das seguintes variáveis
#
# English:
# See the `variables.tf` file for the usage description and the default values of the following variables

database_user = "wordpress"
database_password = "wordpress"
database_name = "wordpress"
database_address = "172.17.0.1"
mysql_root_password = "secret"
dns_address = ["8.8.8.8"]
dns_domain_search = ["domain.com.br"]
container_memory = 1024
port_mysql_external = 3306
port_http_external = 80
port_https_external = 443
dir_host_path = "/docker/mysql/wordpress/data"
