# Visualizando a versao da API do Zabbix
version_api:
  zabbix.apiinfo_version: 
    - _connection_user: {{ pillar['zabbix.user'] }} 
    - _connection_password: {{ pillar['zabbix.password'] }} 
    - _connection_url: {{ pillar['zabbix.url'] }}

