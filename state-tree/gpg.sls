{%- if grains['os_family'] == 'RedHat' and grains['os'] != 'VMware Photon OS' %}
  {%- set gnupg = 'gnupg2' %}
{%- else %}
  {%- set gnupg = 'gnupg' %}
{%- endif %}

gpg:
  pkg.installed:
    - name: {{ gnupg }}
    - aggregate: True
