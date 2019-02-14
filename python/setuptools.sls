{%- if grains['os'] not in ('Windows') %}
include:
  - python.pip
{%- endif %}

setuptools:
  pip.installed:
    - name: "setuptools>=30"
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
{%- if grains['os'] not in ('Windows') %}
    - require:
      - cmd: pip-install
{%- endif %}
