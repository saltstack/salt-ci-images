{%- if grains['os'] == 'Gentoo' %}
  {% set supervisor = 'app-admin/supervisor' %}
{% else %}
  {% set supervisor = 'supervisor' %}
{%- endif %}

supervisor:
  pkg.installed:
    - name: {{ supervisor }}
    - aggregate: True
