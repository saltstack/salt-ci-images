{% from 'libsodium.sls' import libsodium with context %}

include:
  - python.pip
  - libsodium

libnacl:
  pip.installed:
    - require:
      - cmd: pip-install
      - pkg: {{ libsodium }}

