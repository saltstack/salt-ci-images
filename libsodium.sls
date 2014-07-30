{%- if grains['os'] == 'Gentoo' %}
  {% set libsodium = 'dev-libs/libsodium' %}
{% elif grains['os'] == 'openSUSE' %}
  {% set libsodium = 'libsodium-devel' %}
{%- else %}
  {% set libsodium = 'libsodium' %}
{%- endif %}

libsodium:
  pkg.installed:
    - name: {{ libsodium }}
