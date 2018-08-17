{% if grains['os'] not in ('Windows',) %}
include:
  - gcc
  - python.pip
{% endif %}

{% for cpkg in ['m2crypto', 'pycrpyto'] %}
remove-{{cpkg}}:
  pip.removed:
    - name: {{cpkg}}
{% endfor %}

pycryptodome:
  pip.installed:
    - name: pycryptodome >= 3.6.5
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
      - pip: remove-m2crpyto
      - pip: remove-pycrpyto
      - pkg: gcc
{% endif %}
