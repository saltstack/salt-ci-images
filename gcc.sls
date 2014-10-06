{% if grains['os'] == 'SmartOS' %}
  {% set gcc = 'gcc47' %}
{% else %}
  {% set gcc = 'gcc' %}
{% endif %}

{%- if grains['os'] == 'Arch' %}
gcc-multilib:
  pkg.removed
{%- endif %}

gcc:
  pkg.installed:
    - name: {{ gcc }}
    {%- if grains['os'] == 'Arch' %}
    - require:
      - pkg: gcc-multilib
    {%- endif %}
