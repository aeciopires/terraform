# Português

* Será necessário você criar uma conta na Amazon AWS. Crie uma conta 'Free Tier' na Amazon https://aws.amazon.com/ siga as instruções das páginas: https://docs.aws.amazon.com/chime/latest/ag/aws-account.html e https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier-limits.html. Na criação da conta será necessário cadastrar um cartão de crédito, mas como você criará instâncias usando os recursos oferecidos pelo plano 'Free Tier', nada será cobrado se você não ultrapassar o limite para o uso dos recursos e tempo oferecidos e descritos no link anterior.
* Após a criação da conta na AWS, acesse a interface CLI da Amazon na página: https://aws.amazon.com/cli/
* Clique no nome do usuário (canto superior direito) e escolha a opção "Security Credentials". Em seguida clique na opção "Access Keys (Access Key ID and Secret Access Key)" e clique no botão "New Access Key" para criar e visualizar o ID e o Secret da chave, conforme exemplo abaixo (https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html). A Access Key e Secret Key mostradas a seguir são apenas para exemplo. Elas são inválidas e você precisa trocar pelos dados reais gerados para sua conta.

```bash
Access Key ID: AKIAI3IZDFASDFASDFAS2OSCH7MDV3SQ
Secret Access Key: y+7sVdfsdfsZMfOSsdfasdfasfdfasdfasSHT
```

* Crie o diretório abaixo.

No Linux:

```bash
mkdir -p /home/NOME_USUARIO/.aws/
```

No Windows:

```bash
mkdir c:\Users\NOME_USUARIO\.aws/
```

* Acesse o diretório criado anteriormente e crie o arquivo ``credentials`` com o seguinte conteúdo. A Access Key e Secret Key mostradas a seguir são apenas para exemplo. Elas são inválidas e você precisa trocar pelos dados reais gerados para sua conta.

```bash
[default]
aws_access_key_id = AKIAI3IZDFASDFASDFAS2OSCH7MDV3SQ
aws_secret_access_key = y+7sVdfsdfsZMfOSsdfasdfasfdfasdfasSHT
```

* Este projeto contém o arquivo ``template.tf`` que define as configurações gerais do Google Cloud. Ele contém também o arquivo ``variables.tf`` onde você pode definir os valores das variáveis usadas pelo ``template.tf``.
* O subdiretório ``modules/application`` possui o arquivo ``application.tf``, que define a criação das instancias. Ele contém também o arquivo ``variables.tf``, onde você pode definir os valores das variáveis usadas pelo ``application.tf``.
* Altere os valores de acordo com a necessidade.
* O objetivo é criar 3 instâncias e liberar o acesso remoto.
* O arquivo ``graph.png`` mostra o relacionamento entre os recursos gerenciados pelo Terraform.

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

No Windows, você pode baixar e descompactar o Terraform em C:\ e executá-lo no prompt do windows com a sintaxe abaixo.

```bash
C:\\terraform [opções]
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

Linux:

```bash
mkdir -p /home/NOME_USUARIO/.aws/
```

Windows:

```bash
mkdir c:\Users\NOME_USUARIO\.aws/
```

* Access the directory created previously and create the ``credentials`` file with the following content. The Access Key and Secret Key shown below are for illustration only. They are invalid and you need to exchange for the actual data generated for your account.

```bash
[default]
aws_access_key_id = AKIAI3IZDFASDFASDFAS2OSCH7MDV3SQ
aws_secret_access_key = y+7sVdfsdfsZMfOSsdfasdfasfdfasdfasSHT
```
* This project contains the ``template.tf`` file that defines the general Google Cloud settings. It also contains the ``variables.tf`` file where you can set the option values by ``template.tf``.
* The ``modules/application`` subdirectory has the ``application.tf`` file that defines the creation of instances. It also contains the variables.tf file where you can define the values of the variables used by ``application.tf``.
* Change the values according to the need.
* The goal is to create 3 instances and release the remote access.
* The ``graph.png`` file shows the relationship between the resources managed by Terraform.

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

On Windows, you get and extract the Terraform on C:\ and execute on prompt with sintax bellow.

```bash
C:\\terraform [options]
```
