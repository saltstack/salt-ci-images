{%- set virtualenv_pin = '' if grains['os'] == 'MacOS' else '==1.10' %}

include:
  - python.pip

virtualenv:
  pip.installed:
    - name: virtualenv{{ virtualenv_pin }}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: pip-install
