{%- set os_family = salt['grains.get']('os_family', '') %}
{%- if os_family == 'Debian' %}
  {%- set service_name = 'ssh' %}
{%- else %}
  {%- set service_name = 'sshd' %}
{%- endif %}

include:
  - sshd_config

restart-sshd:
  service.running:
    - name: {{ service_name }}
    - enable: True
    - reload: True
    - require:
      - sshd_config
