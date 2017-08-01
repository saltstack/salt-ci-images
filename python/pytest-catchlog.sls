{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

pytest-catchlog:
  pip.installed:
    - name: git+https://github.com/eisensheng/pytest-catchlog.git@develop#egg=Pytest-catchlog
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi.c7.saltstack.net/simple
    - extra_index_url: https://pypi.python.org/simple
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
