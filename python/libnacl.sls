include:
  - python.pip
  - libsodium

libnacl:
  pip.installed:
    - require:
      - cmd: pip-install
      - libsodium

