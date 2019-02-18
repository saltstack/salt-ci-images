{# dockerd is required for the zookeeper test #}
include:
  - docker
  - python.pip

install kazoo:
  pip.installed:
    - name: kazoo
    - require:
      - cmd: pip-install
