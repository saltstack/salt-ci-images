{% set dhclient_conf = '/etc/dhcp/dhclient.conf' %}

{%- if salt['file.file_exists'](dhclient_conf) %}
dhclient_conf.lease_time:
  file.line:
    - name: {{ dhclient_conf }}
    - content: "supersede dhcp-lease-time 86400;"
    - mode: insert
    - location: end
{%- endif %}
