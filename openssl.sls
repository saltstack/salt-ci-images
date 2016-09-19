{%- if grains['os'] in ('MacOS', 'Debian') %}
openssl:
  pkg.installed:
    - name: openssl
{%- endif %}
