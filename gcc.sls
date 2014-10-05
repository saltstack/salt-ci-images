{% if grains['os'] == 'SmartOS' %}
  {% set gcc = 'gcc47' %}
{% elif grains['os'] == 'Arch' %}
  {% set gcc = 'gcc-multilib' %}
{% else %}
  {% set gcc = 'gcc' %}
{% endif %}

gcc:
  pkg.installed:
    - name: {{ gcc }}
