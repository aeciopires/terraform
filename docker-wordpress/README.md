# Português

1. Este diretório contém o arquivo ``template.tf`` que define as configurações gerais do Docker e de autenticação no Docker Registry. Ele contém também o arquivo ``variables.tf`` onde você pode definir os valores das variáveis usadas pelo ``template.tf``.
2. O subdiretório ``modules/application`` possui o arquivo ``application.tf`` que define a criação dos conteineres mysql e wordpress. Ele contém também o arquivo ``variables.tf`` onde você pode definir os valores das variáveis usadas pelo ``application.tf``.
3. Altere os valores de acordo com a necessidade.
4. O objetivo é instalar o Wordpress e disponibilizar o acesso na porta 80/TCP do host que executa o conteiner.
5. O arquivo ``graph.png`` mostra o relacionamento entre os recursos gerenciados pelo Terraform.

Fonte: http://blog.aeciopires.com/instalando-o-wordpress-via-docker

# English

1. This directory contains the ``template.tf`` file that defines the general Docker settings and authentication in the Docker Registry. It also contains the ``variables.tf`` file where you can define the values of the variables used by ``template.tf``.
2. The ``modules/application`` subdirectory has the ``application.tf`` file that defines the creation of the mysql and wordpress containers. It also contains the ``variables.tf`` file where you can define the values of the variables used by ``application.tf``.
3. Change the values according to the need.
4. The goal is to install Wordpress and provide access on port 80/TCP of the host that runs the container.
5. The ``graph.png`` file shows the relationship between the resources managed by Terraform.

Font: http://blog.aeciopires.com/instalando-o-wordpress-via-docker
