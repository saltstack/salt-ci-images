{%- if grains['os_family'] == 'Debian' %}
  {% set libffi = 'libffi-dev' %}
{%- elif grains['os_family'] == 'RedHat' %}
  {% set libffi = 'libffi-devel' %}
{%- else %}
  {% set libffi = 'libffi' %}
{% endif %}

libffi:
  pkg.installed
    - name: {{ libffi }}
