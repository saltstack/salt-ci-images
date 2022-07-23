{%- if grains['os_family'] == 'RedHat' and grains['os'] != 'VMware Photon OS' %}
  {%- set gnupg = 'gnupg2' %}
{%- elif grains['os_family'] == 'Suse' %}
  {%- set gnupg = 'gpg2' %}
{%- else %}
  {%- set gnupg = 'gnupg' %}
{%- endif %}

gnupg:
  pkg.installed:
    - name: {{ gnupg }}
