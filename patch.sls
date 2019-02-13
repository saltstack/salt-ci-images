{%- if grains['os'] == 'Gentoo' %}
  {%- set patch = 'sys-devel/patch' %}
{%- else %}
  {%- set patch = 'patch' %}
{%- endif %}

{%- if grains['os'] in ('Windows') %}
  {%- set install_method = 'pip.installed' %}
{%- else %}
  {%- set install_method = 'pkg.installed' %}
{%- endif %}

patch:
  {{ install_method }}:
    - name: {{ patch }}
    {%- if install_method == 'pkg.installed' %}
    - aggregate: True
    {%- endif %}
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
