{%- if salt['grains.get']('os', '') == 'CentOS' and salt.grains.get('osmajorrelease')|int >= 8 %}
  {%- set gnupg = 'gnupg2' %}
{%- elif salt['grains.get']('os', '') == 'Fedora' and salt.grains.get('osmajorrelease')|int >= 30 %}
  {%- set gnupg = 'gnupg2' %}
{%- else %}
  {%- set gnupg = 'gnupg' %}
{%- endif %}

gpg:
  pkg.installed:
    - name: {{ gnupg }}
    - aggregate: True
