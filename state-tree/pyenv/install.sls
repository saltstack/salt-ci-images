{%- set python_version = "3.7.12" %}
include:
  - pyenv.bootstrap
  - pyenv.deps


install-python:
  cmd.run:
    - name: pyenv install -v {{ python_version }}
    - require:
      - install-pyenv
      - install-dependencies


default-python:
  cmd.run:
    - name: pyenv global {{ python_version }}
    - require:
      - install-python
