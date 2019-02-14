{% from 'libsodium.sls' import libsodium with context %}

include:
  - python.pip
  - libsodium

libnacl:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - require:
      - cmd: pip-install
      - pkg: {{ libsodium }}

