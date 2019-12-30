#!/usr/bin/env python3
#-*- coding: utf-8 -*-
#
#+------------------------------------------------------------------------------+
# Description: Cadastra uma lista de host, IP, ID do grupo de host e ID do template
# (previamente cadastrados no Zabbix) e informados em um arquivo no formato CSV
# separados por , e no seguinte padrão:
#
#  host,ip,group_id,template_id
#
# Author: Aecio Pires <http://blog.aeciopires.com/contato>
# Date: 31-Mar-2019
#
# Exemplos de execucao:
#   python3 create_hosts.py CREDENTIALS_FILE PATH_FILE_CSV
#   python3 create_hosts.py /home/$USER/credentials_zabbix_api.txt /home/$USER/hosts.csv
#
# Neste caso, os seguintes dados estao fixos no script:
#   porta do monitoramento Zabbix: 10050
#   porta do monitoramento SNMP: 161
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
# url_zabbix,login_zabbix,senha
#
#
# Atenção:
#
# Dependências: Python3, Python3-Pip e zabbix-api
# Comandos para resolver as dependências no Ubuntu 18.04:
#   sudo apt install -y python3 python3-pip
#   sudo pip3 install zabbix-api
#+------------------------------------------------------------------------------+

import docstring
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

# Lendo e cadastrando cada host encontrado em cada linha do arquivo CSV
with open(FILE, 'rb') as f:
    reader = csv.reader(f, delimiter=',', quoting=csv.QUOTE_NONE)
    for row in  f:
        row_string  = row.decode("utf-8")
        row_list    = row_string.split(',')
        hostname    = row_list[0]
        ip          = row_list[1]
        group_id    = row_list[2]
        template_id = row_list[3]

        #print ("Created host in line: ", f.line_num)
        created_host = zapi.host.create({
            "host": hostname,
            "status": 0,
            "interfaces": [
                {
                    "type": 1,
                    "main": 1,
                    "useip": 1,
                    "ip": ip,
                    "dns": "",
                    "port": 10050
                },
                {
                    "type": 2,
                    "main": 1,
                    "useip": 1,
                    "ip": ip,
                    "dns": "",
                    "port": 161
                }
            ],
            "groups": [
                {
                    "groupid": group_id
                }
            ],
            "templates": [
                {
                    "templateid": template_id
                }
            ],
        })

# Logout da API do Zabbix
exit = zapi.user.logout([])
