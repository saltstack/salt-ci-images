{%- if grains['os_family'] in ('FreeBSD',) %}
  {% set subversion = 'devel/subversion' %}
{% else %}
  {% set subversion = 'subversion' %}
{% endif %}

subversion:
  pkg.installed:
    - name: {{ subversion }}
