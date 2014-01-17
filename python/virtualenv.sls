include:
  - python.pip

virtualenv:
  pip.installed:
    - name: virtualenv==1.10
    - require:
      - cmd: python-pip
