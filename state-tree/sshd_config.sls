{% set ssh_config = '/etc/ssh/sshd_config' %}
{% set on_docker = salt['environ.get']('ON_DOCKER', '0') %}
{% set fifty_redhat_conf = '/etc/ssh/sshd_config.d/50-redhat.conf' %}

sshd_config.ClientAliveInterval:
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

sshd_config.ClientAliveCount:
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

sshd_config.TCPKeepAlive:
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

{%- if grains['os_family'] in ('RedHat') and on_docker %}
{%- if salt['file.file_exists'](fifty_redhat_conf) %}
edit_fifty_redhat_conf:
  file.replace:
    - name: {{ fifty_redhat_conf }}
    - pattern: '(.*)opensshserver.config$'
    - repl: ''
{%- endif %}
{%- endif %}
