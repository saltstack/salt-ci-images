include:
  - python.pip

nose:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', None) }}
    - require:
      - cmd: python-pip
