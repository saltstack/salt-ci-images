{% if grains['os'] == 'SmartOS' %}
  {% set gcc = 'gcc47' %}
{% else %}
  {% set gcc = 'gcc' %}
{% endif %}

gcc:
  pkg.installed:
    - name: {{ gcc }}
