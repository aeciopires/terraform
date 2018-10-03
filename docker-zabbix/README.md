# Português

1. Este diretório contém o arquivo ``template.tf`` que define as configurações
gerais do Docker e de autenticação no Docker Registry. Ele contém também o
arquivo ``variables.tf`` onde você pode definir os valores das variáveis
usadas pelo ``template.tf``.
2. O subdiretório ``modules/application`` possui o arquivo ``application.tf``
que define a criação dos conteineres mysql e zabbix. Ele contém também o arquivo
``variables.tf`` onde você pode definir os valores das variáveis usadas pelo
``application.tf``.
3. Altere os valores de acordo com a necessidade.
4. O objetivo é instalar o Zabbix e disponibilizar o acesso na porta 80/TCP do
host que executa o conteiner.
5. O arquivo ``graph.png`` mostra o relacionamento entre os recursos gerenciados
pelo Terraform.

Comandos mais usados:

* terraform --help    => Exibe a ajuda do comando terraform<br>
* terraform providers => Imprime a árvore de providers usados na configuração<br>
* terraform init      => Inicializa o diretório de trabalho do Terraform<br>
* terraform validate  => Valida a sintaxe dos arquivos do Terraform<br>
* terraform plan      => Gera e exibe o plano de execução (mas não altera nada) <br>
* terraform apply     => Compila e altera a infraestrutura conforme o planejado<br>
* terraform show      => Inspeciona e exibe o estado atual da infraestrutura<br>
* terraform destroy   => Destroi a infraestrutura gerenciada pelo Terraform<br>

# English

1. This directory contains the ``template.tf`` file that defines the general
Docker settings and authentication in the Docker Registry. It also contains
the ``variables.tf`` file where you can define the values of the variables used
by ``template.tf``.
2. The ``modules/application`` subdirectory has the ``application.tf`` file
that defines the creation of the mysql and zabbix containers. It also contains
the ``variables.tf`` file where you can define the values of the variables used
by ``application.tf``.
3. Change the values according to the need.
4. The goal is to install Zabbix and provide access on port 80/TCP of the host
that runs the container.
5. The ``graph.png`` file shows the relationship between the resources managed
by Terraform.

Useful commands:

* terraform --help    => Show help of command terraform<br>
* terraform providers => Prints a tree of the providers used in the configuration<br>
* terraform init      => Initialize a Terraform working directory<br>
* terraform validate  => Validates the Terraform files<br>
* terraform plan      => Generate and show an execution plan<br>
* terraform apply     => Builds or changes infrastructure<br>
* terraform show      => Inspect Terraform state<br>
* terraform destroy   => Destroy Terraform-managed infrastructure<br>
