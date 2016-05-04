{%- if grains['os'] == 'MacOS' %}
openssl:
  pkg.installed:
    - name: openssl
{%- endif %}
