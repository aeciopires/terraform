# Português

* Será necessário você criar uma conta na Amazon AWS. Crie uma conta 'Free Tier' na Amazon https://aws.amazon.com/ siga as instruções das páginas: https://docs.aws.amazon.com/chime/latest/ag/aws-account.html e https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier-limits.html. Na criação da conta será necessário cadastrar um cartão de crédito, mas como você criará instâncias usando os recursos oferecidos pelo plano 'Free Tier', nada será cobrado se você não ultrapassar o limite para o uso dos recursos e tempo oferecidos e descritos no link anterior.
* Após a criação da conta na AWS, acesse a interface CLI da Amazon na página: https://aws.amazon.com/cli/
* Clique no nome do usuário (canto superior direito) e escolha a opção "Security Credentials". Em seguida clique na opção "Access Keys (Access Key ID and Secret Access Key)" e clique no botão "New Access Key" para criar e visualizar o ID e o Secret da chave, conforme exemplo abaixo (https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html). A Access Key e Secret Key mostradas a seguir são apenas para exemplo. Elas são inválidas e você precisa trocar pelos dados reais gerados para sua conta.

```bash
Access Key ID: AKIAI3IZDFASDFASDFAS2OSCH7MDV3SQ
Secret Access Key: y+7sVdfsdfsZMfOSsdfasdfasfdfasdfasSHT
```

* Crie o diretório abaixo.

```bash
mkdir -p /home/NOME_USUARIO/.aws/
```

* Acesse o diretório criado anteriormente e crie o arquivo ``credentials`` com o seguinte conteúdo. A Access Key e Secret Key mostradas a seguir são apenas para exemplo. Elas são inválidas e você precisa trocar pelos dados reais gerados para sua conta.

```bash
[default]
aws_access_key_id = AKIAI3IZDFASDFASDFAS2OSCH7MDV3SQ
aws_secret_access_key = y+7sVdfsdfsZMfOSsdfasdfasfdfasdfasSHT
```

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
3. O objetivo é disponibilizar o OpenProject numa instância da AWS.
4. O arquivo ``graph.png`` mostra o relacionamento entre os recursos gerenciados pelo Terraform.

Comandos mais usados:

* terraform --help    => Exibe a ajuda do comando terraform<br>
* terraform providers => Imprime a árvore de providers usados na configuração<br>
* terraform init      => Inicializa o diretório de trabalho do Terraform<br>
* terraform validate  => Valida a sintaxe dos arquivos do Terraform<br>
* terraform plan      => Gera e exibe o plano de execução (mas não altera nada) <br>
* terraform apply     => Compila e altera a infraestrutura conforme o planejado<br>
* terraform show      => Inspeciona e exibe o estado atual ou planejado da infraestrutura<br>
* terraform destroy   => Destroi a infraestrutura gerenciada pelo Terraform<br>
* terraform output -module=instances => Exibe os resultados do modulo definidos no arquivo ``modules/application/output.tf``.

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
cd terraform/aws_docker_openproject
sudo terraform init
```

* Altere os valores de acordo com a necessidade do ambiente no arquivo ``terraform.tfvars``.

* Valide as configurações e crie o ambiente com os seguintes comandos

```bash
sudo terraform validate
sudo terraform apply -auto-approve
sudo terraform show
```

# English

* You will need to create an Amazon AWS account. Create a 'Free Tier' account at Amazon https://aws.amazon.com/ follow the instructions on the pages: https://docs.aws.amazon.com/chime/latest/ag/aws-account.html and https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier-limits.html. When creating the account you will need to register a credit card, but since you will create instances using the features offered by the 'Free Tier' plan, nothing will be charged if you do not exceed the limit for the use of the features and time offered and described in the previous link .
* After creating the account in AWS, access the Amazon CLI interface at: https://aws.amazon.com/cli/
* Click on the username (upper right corner) and choose the "Security Credentials" option. Then click on the "Access Key and Secret Access Key" option and click the "New Access Key" button to create and view the ID and Secret of the key, as shown below (https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html). The Access Key and Secret Key shown below are for illustration only. They are invalid and you need to exchange for the actual data generated for your account.

```bash
Access Key ID: AKIAI3IZDFASDFASDFAS2OSCH7MDV3SQ
Secret Access Key: y+7sVdfsdfsZMfOSsdfasdfasfdfasdfasSHT
```

* Create the directory below.

```bash
mkdir -p /home/NOME_USUARIO/.aws/
```

* Access the directory created previously and create the ``credentials`` file with the following content. The Access Key and Secret Key shown below are for illustration only. They are invalid and you need to exchange for the actual data generated for your account.

```bash
[default]
aws_access_key_id = AKIAI3IZDFASDFASDFAS2OSCH7MDV3SQ
aws_secret_access_key = y+7sVdfsdfsZMfOSsdfasdfasfdfasdfasSHT
```

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
3. The goal is to install OpenProject and provide access on port 80/TCP the host 
that runs the container.<br>
4. The ``graph.png`` file shows the relationship between the resources managed by Terraform.

Useful commands:

* terraform --help    => Show help of command terraform<br>
* terraform providers => Prints a tree of the providers used in the configuration<br>
* terraform init      => Initialize a Terraform working directory<br>
* terraform validate  => Validates the Terraform files<br>
* terraform plan      => Generate and show an execution plan<br>
* terraform apply     => Builds or changes infrastructure<br>
* terraform show      => Inspect Terraform state or plan<br>
* terraform destroy   => Destroy Terraform-managed infrastructure<br>
* terraform output -module=instances => Show results of module define on ``modules/application/output.tf`` file .

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
sudo terraform init
```

* Change the values according to the need of the environment in the ``terraform.tfvars`` file.

* Validate the settings and create the environment with the following commands

```bash
sudo terraform validate
sudo terraform apply -auto-approve
sudo terraform show
```
