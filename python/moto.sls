{%- if grains['os'] not in ('Windows') %}
include:
  - python.pip
{%- endif %}

{%- if grains['os'] == 'CentOS' and grains['osmajorrelease'] == '6' %}
  {%- set moto_version = 'moto==1.0.1' %}
{%- else %}
  {%- set moto_version = 'moto==1.1.25' %}
{%- endif %}

moto:
  pip.installed:
    - name: {{ moto_version }}
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
{%- if grains['os'] not in ('Windows') %}
    - require:
      - cmd: pip-install
{%- endif %}
