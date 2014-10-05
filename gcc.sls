{% if grains['os'] == 'SmartOS' %}
  {% set gcc = 'gcc47' %}
{% if grains['os'] == 'ARch' %}
{% else %}
  {% set gcc = 'gcc-multilib' %}
{% endif %}

gcc:
  pkg.installed:
    - name: {{ gcc }}
