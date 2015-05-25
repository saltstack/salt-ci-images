{% if grains['os_family'] == 'Debian' %}
    {% set libffi == 'libffi-dev' %}
{% elif grains['os_family'] == 'RedHat' %}
    {% set libffi == 'libffi-devel' %}
{% else libffi == 'libffi' %}

libffi:
  pkg.installed
    - name: {{ libffi }}
