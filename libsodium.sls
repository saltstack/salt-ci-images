{%- if grains['os'] == 'Gentoo' %}
  {% set libsodium = 'dev-libs/libsodium' %}
{% else %}
  {% set libsodium = 'libsodium' %}
{%- endif %}

libsodium:
  pkg.installed:
    - name: {{ libsodium }}
