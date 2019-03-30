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
* terraform init      => Inicializa o diretório de trabalho do Terraform<br>
* terraform providers => Imprime a árvore de providers usados na configuração<br>
* terraform validate  => Valida a sintaxe dos arquivos do Terraform<br>
* terraform plan      => Gera e exibe o plano de execução (mas não altera nada) <br>
* terraform apply     => Compila e altera a infraestrutura conforme o planejado<br>
* terraform show      => Inspeciona e exibe o estado atual da infraestrutura<br>
* terraform destroy   => Destroi a infraestrutura gerenciada pelo Terraform<br>

Tutorial

* Baixe o Terraform para Linux em: https://www.terraform.io/downloads.html
* Descompacte o pacote do Terraform.
* Acesse o diretório descompactado do Terraform.
* Copie o binário do Terraform para o diretório ``/usr/bin`` com os seguintes comandos:

```bash
sudo cp terraform /usr/bin
sudo chmod 755 /usr/bin/terraform
```

* Instale o Docker-CE seguindo as instruções das páginas abaixo de acordo com a
distribuição GNU/Linux.

* Ubuntu:
https://docs.docker.com/install/linux/docker-ce/ubuntu/

* Fedora:
https://docs.docker.com/install/linux/docker-ce/fedora/

* CentOS:
https://docs.docker.com/install/linux/docker-ce/centos/

* Debian:
https://docs.docker.com/install/linux/docker-ce/debian/

* Altere o valor da variárel ``USUARIO`` pelo nome da sua conta no S.O no qual
o Docker foi instalado e execute os comandos abaixo para adicionar o seu usuário
 ao grupo Docker.

```bash
USUARIO="seu-nome-usuario"
sudo usermod -aG docker $USUARIO
sudo setfacl -m user:$USUARIO:rw /var/run/docker.sock
```

OPCIONAL: você pode configurar o Docker para ser inicializado no boot do S.O
seguindo as instruções da página:
https://docs.docker.com/install/linux/linux-postinstall/

* Certifique-se de não ter nenhum conteiner localmente executando nas portas: 80/TCP, 443/TC, 3306/TCP, 10050/TCP e 10051/TCP. Para isso, use os seguintes comandos:

```bash
docker ps -a --format "{{.Ports}}"
```

* Baixe o código fonte deste projeto com os seguintes comandos:

```bash
git clone https://github.com/aeciopires/terraform
cd terraform/docker-zabbix
terraform init
```

* Valide as configurações e crie o ambiente com os seguintes comandos

```bash
terraform validate
terraform apply
terraform show
```

Neste tutorial foi mostrado como instalar o Zabbix usando conteiners Docker executados
localmente, mas o Terraform por gerenciar o Docker em repositórios remotos ou em
instâncias na nuvem. Para saber mais sobre o Terraform, acesse:

* http://blog.aeciopires.com/conhecendo-o-terraform/
* https://www.terraform.io/docs/index.html

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
* terraform init      => Initialize a Terraform working directory<br>
* terraform providers => Prints a tree of the providers used in the configuration<br>
* terraform validate  => Validates the Terraform files<br>
* terraform plan      => Generate and show an execution plan<br>
* terraform apply     => Builds or changes infrastructure<br>
* terraform show      => Inspect Terraform state<br>
* terraform destroy   => Destroy Terraform-managed infrastructure<br>

Tutorial

* Download Terraform for Linux: https://www.terraform.io/downloads.html
* Unpack the Terraform package.
* Access the unpacked directory.
* Copy the Terraform binary to the ``/usr/bin`` directory with the following commands:

```bash
sudo cp terraform /usr/bin
sudo chmod 755 /usr/bin/terraform
```

* Install Docker-CE by following the instructions on the following pages according to the GNU/Linux distribution.

* Ubuntu:
https://docs.docker.com/install/linux/docker-ce/ubuntu/

* Fedora:
https://docs.docker.com/install/linux/docker-ce/fedora/

* CentOS:
https://docs.docker.com/install/linux/docker-ce/centos/

* Debian:
https://docs.docker.com/install/linux/docker-ce/debian/

* Change the value of the ``USER``variable by the name of your account in the S.O in which Docker has been installed and run the commands below to add your user
 to the Docker group.

```bash
USER="your-username"
sudo usermod -aG docker $USER
sudo setfacl -m user:$USER:rw /var/run/docker.sock
```

OPTIONAL: You can configure Docker to boot from the S.O following the instructions on the page:
https://docs.docker.com/install/linux/linux-postinstall/

* Ensure that you do not have any containers locally running on the ports: 80/TCP, 443/TCP, 3306/TCP, 10050/TCP and 10051/TCP. To do this, use the following commands:

```bash
docker ps -a --format "{{.Ports}}"
```

* Download the source code of this project with the following commands:

```bash
git clone https://github.com/aeciopires/terraform
cd terraform/docker-zabbix
terraform init
```

* Validate the settings and create the environment with the following commands

```bash
terraform validate
terraform apply
terraform show
```

This tutorial showed you how to install Zabbix using Docker locally, but Terraform for managing Docker in remote repositories or in instances in the cloud. To learn more about Terraform, visit:

* http://blog.aeciopires.com/conhecendo-o-terraform/
* https://www.terraform.io/docs/index.html
