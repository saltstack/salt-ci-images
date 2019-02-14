{%- if grains['os'] == 'FreeBSD' %}
  {%- set sed = 'gsed' %}
{%- else %}
  {%- set sed = 'sed' %}
{%- endif %}

{% if grains['os'] in ('Windows') %}
  {% set install_method = 'pip.installed' %}
{% else %}
  {% set install_method = 'pkg.installed' %}
{% endif %}

sed:
  {{ install_method }}:
    - name: {{ sed }}
    {% if install_method == 'pkg.installed' %}
    - aggregate: True
    {%- endif %}
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
