{% set new_coverage = pillar.get('new_coverage', False) %}

include:
  - python.pip

coverage:
  pip.installed:
    {%- if new_coverage %}
    - name: 'coverage'
    {%- else %}
    - name: 'coverage==3.7.1'
    {%- endif %}
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: pip-install
