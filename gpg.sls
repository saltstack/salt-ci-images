{% if grains['os_family'] == 'RedHat' %}
  {% set gpg = 'gpg' %}
{% elif grains['os_family'] in ['Arch', 'Debian'] %}
  {% set gpg = 'gnupg' %}
{% endif %}

gpg:
  pkg.installed:
    - name: {{ gpg }}
