{% set ssh_config = '/etc/ssh/sshd_config' %}

ClientAliveInterval:
  file.line:
    - name: {{ ssh_config }}
    - content: "ClientAliveInterval 60"
  {%- if salt['file.search'](ssh_config, 'ClientAliveInterval') %}
    - match: "(#)?.*ClientAliveInterval.*"
    - mode: "replace"
  {%- else %}
    - mode: insert
    - location: end
  {%- endif %}

ClientAliveCount:
  file.line:
    - name: {{ ssh_config }}
    - content: "ClientAliveCountMax 20"
  {%- if salt['file.search'](ssh_config, 'ClientAliveCountMax') %}
    - match: "(#)?.*ClientAliveCountMax.*"
    - mode: "replace"
  {%- else %}
    - mode: insert
    - location: end
  {%- endif %}

TCPKeepAlive:
  file.line:
    - name: {{ ssh_config }}
    - content: "TCPKeepAlive yes"
  {%- if salt['file.search'](ssh_config, 'TCPKeepAlive') %}
    - match: "(#)?.*TCPKeepAlive.*"
    - mode: "replace"
  {%- else %}
    - mode: insert
    - location: end
  {%- endif %}


stop-sshd:
  service.dead:
    {%- if grains['os'] == 'Ubuntu' and grains['osmajorrelease'] >= 23 %}
    - name: ssh
    {%- else %}
    - name: sshd
    {%- endif %}
    - enable: True
    - require:
      - ClientAliveInterval
      - ClientAliveCount
      - TCPKeepAlive


start-sshd:
  service.enabled:
    {%- if grains['os'] == 'Ubuntu' and grains['osmajorrelease'] >= 23 %}
    - name: ssh
    {%- else %}
    - name: sshd
    {%- endif %}
    - enable: True
    - reload: True
    - require:
      - stop-sshd
