{# workaround only needs to be in 2016.11 branch #}
{%- if grains['os'] in ('MacOS') %}
  {% set pythonpath = 'export PATH=/opt/salt/bin/:$PATH' %}
{% endif %}
python-path:
  file.append:
    - name: /etc/profile
    - text: |
        {{ pythonpath }}
