{%- if grains['os'] == 'Gentoo' %}
  {% set curl = 'net-misc/curl' %}
{% else %}
  {% set curl = 'curl' %}
{%- endif %}

curl:
  pkg.installed:
    - name: {{ curl }}
