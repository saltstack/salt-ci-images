{% if grains['os'] not in ('Windows') %}
include:
  - python.pip
{% endif %}

pytest-catchlog:
  pip.installed:
    - name: git+https://github.com/s0undt3ch/pytest-catchlog.git@features/full-logging#egg=Pytest-catchlog
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
{% if grains['os'] not in ('Windows') %}
    - require:
      - cmd: pip-install
{% endif %}
