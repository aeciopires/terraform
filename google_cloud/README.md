# Português

OBS.: Desenvolvido usando a sintaxe do Terraform 0.11.x.

0. Será necessário você criar uma conta no Google Cloud (https://cloud.google.com) e, em seguida, baixar o arquivo com as credenciais em https://console.cloud.google.com/apis/credentials/serviceaccountkey
1. Este diretório contém os arquivos:
   * ``main.tf``          => que define as configurações gerais. 
   * ``variables.tf``     => onde você pode definir os valores das variáveis
usadas pelo ``main.tf``.
   * ``terraform.tfvars`` => onde você pode customizar os valores padrão 
a serem usados pelo modulo para se adequar as necessidades do seu ambiente.
2. O subdiretório ``modules/application`` possui os arquivos:
   * ``application.tf``   => que define a criação das instâncias.
   * ``variables.tf``     => onde são definidos os valores padrão a serem 
aplicados pelo arquivo ``application.tf``. Esses valores serão usados quando 
cada variavel não for customizada no arquivo ``terraform.tfvars``.
3. Altere os valores de acordo com a necessidade.
4. O objetivo é criar 3 instâncias e liberar o acesso remoto.
5. O arquivo ``graph.png`` mostra o relacionamento entre os recursos gerenciados pelo Terraform.

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

* Baixe o Terraform para Linux em: https://www.terraform.io/downloads.html
* Descompacte o pacote do Terraform.
* Acesse o diretório descompactado do Terraform.
* Copie o binário do Terraform para o diretório ``/usr/bin`` com os seguintes comandos:

```bash
sudo cp terraform /usr/bin
sudo chmod 755 /usr/bin/terraform
```

* Baixe o código fonte deste projeto com os seguintes comandos:

```bash
git clone https://github.com/aeciopires/terraform
cd terraform/google_cloud
terraform init
```

* Altere os valores de acordo com a necessidade do ambiente no arquivo ``terraform.tfvars``.

* Valide as configurações e crie o ambiente com os seguintes comandos

```bash
terraform validate
terraform apply -auto-approve
terraform show
```

# English

NOTE: Developed using Terraform 0.11.x syntax.

0. You do not need to create a Google Cloud account (https://cloud.google.com) and then download the file with credentials at https://console.cloud.google.com/apis/credentials/serviceaccountkey
1. This directory contains the files:<br>
   * ``template.tf``      => that defines the general settings.<br>
   * ``variables.tf``     => where you can define the values of the variables
used by ``main.tf``.<br>
   * ``terraform.tfvars`` => where you can customize default values
to be used by the module to suit the needs of your environment.
2. The ``modules/application`` subdirectory has the following files:<br>
   * ``application.tf``   => that defines the creation of instances.<br>
   * ``variables.tf``     => where the default values to be defined are applied by 
``application.tf`` file. These values will be used when
each variable is not customized in the ``terraform.tfvars`` file.<br>
3. Change the values according to the need.
4. The goal is to create 3 instances and release the remote access.
5. The ``graph.png`` file shows the relationship between the resources managed by Terraform.

Useful commands:

* terraform --help    => Show help of command terraform<br>
* terraform providers => Prints a tree of the providers used in the configuration<br>
* terraform init      => Initialize a Terraform working directory<br>
* terraform validate  => Validates the Terraform files<br>
* terraform plan      => Generate and show an execution plan<br>
* terraform apply     => Builds or changes infrastructure<br>
* terraform show      => Inspect Terraform state or plan<br>
* terraform destroy   => Destroy Terraform-managed infrastructure<br>

## How to

* Download Terraform for Linux: https://www.terraform.io/downloads.html
* Unpack the Terraform package.
* Access the unpacked directory.
* Copy the Terraform binary to the ``/usr/bin`` directory with the following commands:

```bash
sudo cp terraform /usr/bin
sudo chmod 755 /usr/bin/terraform
```

* Download the source code of this project with the following commands:

```bash
git clone https://github.com/aeciopires/terraform
cd terraform/aws_docker_openproject
terraform init
```

* Change the values according to the need of the environment in the ``terraform.tfvars`` file.

* Validate the settings and create the environment with the following commands

```bash
terraform validate
terraform apply -auto-approve
terraform show
```