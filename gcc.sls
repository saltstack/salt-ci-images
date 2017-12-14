{% if grains['os'] == 'SmartOS' %}
  {% set gcc = 'gcc47' %}
{% else %}
  {% set gcc = 'gcc' %}
{% endif %}

{%- if grains['os'] == 'Arch' %}
gcc-multilib:
  pkg.removed

{%- else -%}
gcc:
  pkg.installed:
    - name: {{ gcc }}
    - aggregate: True
{%- endif %}
