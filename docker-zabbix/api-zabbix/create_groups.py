#!/usr/bin/env python3
#
#------------------------------------------------------------------------------
# Description: Cadastra uma lista de grupo de hosts informados em um arquivo no formato CSV
# (separados por ',' e o grupo de host deve ser informado um por linha).
#
# Author: Aecio Pires <http://blog.aeciopires.com/contato>
# Date: 31-Mar-2019
#
# Exemplos de execucao:
#   python3 create_groups.py CREDENTIALS_FILE PATH_FILE_CSV
#   python3 create_groups.py /home/$USER/credentials_zabbix_api.txt /home/$USER/hostgroups.csv
#
# Ao acessar a API do Zabbix serão requeridos os seguintes dados:
#
# URL do Zabbix. Exemplo: http://172.17.0.1/zabbix
# Login. Exemplo: Admin
# Senha. Exemplo: zabbix
#
# Para que esses dados NÃO sejam solicitados interativamente ou sejam armazenados
# diretamente em cada script deste diretório, você precisa criar o arquivo
# /home/USUARIO/credentials_zabbix_api.txt, com o seguinte conteúdo e passá-lo
# como parametro ao script.
#
#
# url_zabbix,login_zabbix,senha
#
# Atenção:
#
# Dependências: Python3, Python3-Pip e zabbix-api
# Comandos para resolver as dependências no Ubuntu 18.04:
#   sudo apt install -y python3 python3-pip
#   sudo pip3 install zabbix-api
#------------------------------------------------------------------------------

import sys
import csv
from zabbix_api import ZabbixAPI

# Definindo variaveis
CREDENTIALS_FILE = sys.argv[1]
FILE = sys.argv[2]

# Lendo as credenciais
with open(CREDENTIALS_FILE) as f:
    CREDENTIALS = [x.strip().split(',') for x in f.readlines()]
    for url, username, password in CREDENTIALS:
        # Passando as credenciais para a API do Zabbix
        zapi = ZabbixAPI(server=url, timeout=120)
        zapi.login(username, password)

# Lendo e cadastrando o grupo encontrado em cada linha do arquivo CSV
with open(FILE, 'rb') as f:
    reader = csv.reader(f, delimiter=',', quoting=csv.QUOTE_NONE)
    for group in f:
        #print ("Create group in line: ", f.line_num)
        created_group = zapi.hostgroup.create({
            "name": group,
        })

# Logout da API do Zabbix
exit = zapi.user.logout
