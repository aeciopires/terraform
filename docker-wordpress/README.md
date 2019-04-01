# Português

1. Este diretório contém os arquivos:
   * ``main.tf``          => que define as configurações gerais. 
   * ``variables.tf``     => onde você pode definir os valores das variáveis
usadas pelo ``main.tf``.
   * ``terraform.tfvars`` => onde você pode customizar os valores padrão 
a serem usados pelo modulo para se adequar as necessidades do seu ambiente.
2. O subdiretório ``modules/application`` possui os arquivos:
   * ``application.tf`` => que define a criação dos conteineres mysql e 
wordpress.
   * ``variables.tf``   => onde são definidos os valores padrão a serem 
aplicados pelo arquivo ``application.tf``. Esses valores serão usados quando 
cada variavel não for customizada no arquivo ``terraform.tfvars``.
3. O objetivo é instalar o Wordpress e disponibilizar o acesso na porta 80/TCP 
do host que executa o conteiner.
4. O arquivo ``graph.png`` mostra o relacionamento entre os recursos 
gerenciados pelo Terraform.

Comandos mais usados:

* terraform --help    => Exibe a ajuda do comando terraform<br>
* terraform providers => Imprime a árvore de providers usados na configuração<br>
* terraform init      => Inicializa o diretório de trabalho do Terraform<br>
* terraform validate  => Valida a sintaxe dos arquivos do Terraform<br>
* terraform plan      => Gera e exibe o plano de execução (mas não altera nada) <br>
* terraform apply     => Compila e altera a infraestrutura conforme o planejado<br>
* terraform show      => Inspeciona e exibe o estado atual ou planejado da infraestrutura<br>
* terraform destroy   => Destroi a infraestrutura gerenciada pelo Terraform<br>

## Tutorial

* Configure o comando ``sudo`` para não pedir a senha: https://www.vivaolinux.com.br/dica/Liberar-comandos-de-root-no-sudo-sem-pedir-senha
* Baixe o Terraform para Linux em: https://www.terraform.io/downloads.html
* Descompacte o pacote do Terraform.
* Acesse o diretório descompactado do Terraform.
* Copie o binário do Terraform para o diretório ``/usr/bin`` com os seguintes comandos:

```bash
sudo cp terraform /usr/bin
sudo chmod 755 /usr/bin/terraform
```

* Caso já possua o Docker instalado, certifique-se de não ter nenhum conteiner 
localmente executando nas portas: 80/TCP, 443/TCP e 3306/TCP. Para isso, use os 
seguintes comandos:

```bash
docker ps -a --format "{{.Ports}}"
```

* Baixe o código fonte deste projeto com os seguintes comandos:

```bash
git clone https://github.com/aeciopires/terraform
cd terraform/docker-wordpress
sudo terraform init
```

* Altere os valores de acordo com a necessidade do ambiente no arquivo ``terraform.tfvars``.

* Valide as configurações e crie o ambiente com os seguintes comandos

```bash
sudo terraform validate
sudo terraform apply -auto-approve
sudo terraform show
```

Neste tutorial foi mostrado como instalar o Wordpress usando conteiners Docker executados
localmente, mas o Terraform por gerenciar o Docker em repositórios remotos ou em
instâncias na nuvem. Para saber mais sobre o Terraform, acesse:

* http://blog.aeciopires.com/conhecendo-o-terraform/
* https://www.terraform.io/docs/index.html

# English

1. This directory contains the files:<br>
   * ``template.tf``      => that defines the general settings.<br>
   * ``variables.tf``     => where you can define the values of the variables
used by ``main.tf``.<br>
   * ``terraform.tfvars`` => where you can customize default values
to be used by the module to suit the needs of your environment.
2. The ``modules/application`` subdirectory has the following files:<br>
   * ``application.tf`` => that defines the creation of mysql and wordpress.<br>
   * ``variables.tf``   => where the default values to be defined are applied by 
``application.tf`` file. These values will be used when
each variable is not customized in the ``terraform.tfvars`` file.<br>
3. The goal is to install Wordpress and provide access on port 80/TCP the host 
that runs the container.<br>
4. The ``graph.png`` file shows the relationship between the managed by Terraform.


Useful commands:

* terraform --help    => Show help of command terraform<br>
* terraform init      => Initialize a Terraform working directory<br>
* terraform providers => Prints a tree of the providers used in the configuration<br>
* terraform validate  => Validates the Terraform files<br>
* terraform plan      => Generate and show an execution plan<br>
* terraform apply     => Builds or changes infrastructure<br>
* terraform show      => Inspect Terraform state<br>
* terraform destroy   => Destroy Terraform-managed infrastructure<br>

## How to

* Configure the ``sudo`` command without a password: https://www.cyberciti.biz/faq/linux-unix-running-sudo-command-without-a-password/ 
* Download Terraform for Linux: https://www.terraform.io/downloads.html
* Unpack the Terraform package.
* Access the unpacked directory.
* Copy the Terraform binary to the ``/usr/bin`` directory with the following commands:

```bash
sudo cp terraform /usr/bin
sudo chmod 755 /usr/bin/terraform
```

* If you already have Docker installed, ensure that you do not have any containers locally 
running on the ports: 80/TCP, 443/TCP and 3306/TCP. To do this, use 
the following commands:

```bash
docker ps -a --format "{{.Ports}}"
```

* Download the source code of this project with the following commands:

```bash
git clone https://github.com/aeciopires/terraform
cd terraform/docker-wordpress
terraform init
```

* Change the values according to the need of the environment in the ``terraform.tfvars`` file.

* Validate the settings and create the environment with the following commands

```bash
terraform validate
terraform apply -auto-approve
terraform show
```

This tutorial showed you how to install Wordpress using Docker locally, but Terraform for 
managing Docker in remote repositories or in instances in the cloud. To learn more about 
Terraform, visit:

* http://blog.aeciopires.com/conhecendo-o-terraform/
* https://www.terraform.io/docs/index.html


