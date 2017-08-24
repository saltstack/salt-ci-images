{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

install_moto:
  pip.installed:
    - name: moto
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
