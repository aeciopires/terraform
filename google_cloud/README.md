# Português

0. Será necessário você criar uma conta no Google Cloud (https://cloud.google.com) e, em seguida, baixar o arquivo com as credenciais em https://console.cloud.google.com/apis/credentials/serviceaccountkey
1. Este diretório contém o arquivo ``template.tf`` que define as configurações gerais do Google Cloud. Ele contém também o arquivo ``variables.tf`` onde você pode definir os valores das variáveis usadas pelo ``template.tf``.
2. O subdiretório ``modules/application`` possui o arquivo ``application.tf`` que define a criação das instâncias.
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

# English

0. You do not need to create a Google Cloud account (https://cloud.google.com) and then download the file with credentials at https://console.cloud.google.com/apis/credentials/serviceaccountkey
1. This directory contains the ``template.tf`` file that defines the general Google Cloud settings. It also contains the ``variables.tf`` file where you can set the option values by ``template.tf``.
2. The ``modules/application`` subdirectory has the ``application.tf`` file that defines the creation of the instances.
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
