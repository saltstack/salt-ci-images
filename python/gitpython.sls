{% set python26 = True if grains['pythonversion'] < [2, 7] else False %}
include:
  - python.pip

gitpython:
  pip.installed:
    {% if python26 %}
    - name: 'gitpython==2.0.3'
    {% endif %}
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: pip-install

