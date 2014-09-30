include:
  - python.pip

virtualenv:
  pip.installed:
    - name: virtualenv==1.10
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: python-pip
