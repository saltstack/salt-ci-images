{%- if grains['os'] == 'SmartOS' %}
  {%- set gcc = 'gcc47' %}
{%- elif grains['os'] == 'Arch' %}
  {%- if salt['pkg.list_repo_pkgs']('gcc-multilib') %}
    {%- set gcc = 'gcc-multilib' %}
  {%- else %}
    {%- set gcc = 'gcc' %}
  {%- endif %}
{%- else %}
  {%- set gcc = 'gcc' %}
{%- endif %}

{%- if grains['os'] == 'Arch' and gcc == 'gcc' %}
gcc-multilib:
  pkg.removed
{%- endif %}

gcc:
  pkg.installed:
    - name: {{ gcc }}
    - aggregate: True
