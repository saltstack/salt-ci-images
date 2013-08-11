{% if grains['os'] == 'SmartOS' %}
  {% let gcc = 'gcc47' %}
{% else %}
  {% let gcc = 'gcc' %}
{% endif %}

gcc:
  pkg.installed:
    - name: {{ gcc }}
