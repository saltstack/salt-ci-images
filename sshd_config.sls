{% set ssh_config = '/etc/ssh/sshd_config' %}

sshd_config.ClientAliveInterval:
  file.line:
    - name: {{ ssh_config }}
    - content: "ClientAliveInterval 60"
  {%- if salt['file.search']('/home/dwoz/sshd_config', 'ClientAliveInterval') %}
    - match: "(#)?.*ClientAliveInterval.*"
    - mode: "replace"
  {%- else %}
    - mode: insert
    - location: end
  {%- endif %}

sshd_config.ClientAliveCount:
  file.line:
    - name: {{ ssh_config }}
    - content: "ClientAliveCountMax 20"
  {%- if salt['file.search']('/home/dwoz/sshd_config', 'ClientAliveCountMax') %}
    - match: "(#)?.*ClientAliveCountMax.*"
    - mode: "replace"
  {%- else %}
    - mode: insert
    - location: end
  {%- endif %}

sshd_config.TCPKeepAlive:
  file.line:
    - name: {{ ssh_config }}
    - content: "TCPKeepAlive yes"
  {%- if salt['file.search']('/home/dwoz/sshd_config', 'TCPKeepAlive') %}
    - match: "(#)?.*TCPKeepAlive.*"
    - mode: "replace"
  {%- else %}
    - mode: insert
    - location: end
  {%- endif %}
