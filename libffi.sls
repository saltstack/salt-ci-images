{%- if grains['os_family'] == 'Debian' %}
  {% set ffi = 'libffi-dev' %}
{%- elif grains['os_family'] == 'RedHat' %}
  {% set ffi = 'libffi-devel' %}
{%- else %}
  {% set ffi = 'libffi' %}
{%- endif %}

libffi:
  pkg.installed:
    - name: {{ ffi }}
