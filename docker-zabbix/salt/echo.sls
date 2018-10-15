access_zabbix_api:
  cmd.run:
    - name: echo " {{ pillar['url_zabbix_api'] }},{{ pillar['login'] }},{{ pillar['password'] }}"
