echo_variables_pillar:
  cmd.run:
    - name: echo -e "URL => {{ pillar['zabbix.url'] }}\nLOGIN => {{ pillar['zabbix.user'] }}\nPASSWORD => {{ pillar['zabbix.password'] }}"
