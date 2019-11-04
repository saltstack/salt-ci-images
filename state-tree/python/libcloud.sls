include:
  - python.pip
  - python.requests


apache-libcloud:
  pip.installed:
    - name: 'apache-libcloud'
    - require:
      - pip-install
      - requests
