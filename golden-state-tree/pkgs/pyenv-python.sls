{%- set target_python = "3.10.10" %}
include:
  - pkgs.curl
  - pkgs.make
  - pkgs.xz
  - pkgs.curl
  - pkgs.zlib
  - pkgs.openssl-dev
  - pkgs.libffi
  - pkgs.libxml


install-dependencies:
  pkg.installed:
    - pkgs:
    {%- if grains['os_family'] == 'RedHat' %}
      - gcc
      - make
      - zlib-devel
      - bzip2
      - bzip2-devel
      - readline-devel
      - sqlite
      - sqlite-devel
      - openssl-devel
      - tk-devel
      - libffi-devel
      - xz-devel
    {%- elif grains['os_family'] == 'Debian' %}
      - build-essential
      - libssl-dev
      - zlib1g-dev
      - libbz2-dev
      - libreadline-dev
      - libsqlite3-dev
      - libncursesw5-dev
      - xz-utils
      - tk-dev
      - libxml2-dev
      - libxmlsec1-dev
      - libffi-dev
      - liblzma-dev
    {%- else %}
      - failing-on-purpose
    {%- endif %}

bootstrap-pyenv:
  cmd.run:
    - name: curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
    - require:
      - curl
      - install-dependencies

update-bashrc:
  file.append:
    - name: /root/.bash_profile
    - text:
      - 'export PYENV_ROOT="$HOME/.pyenv"'
      - 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
      - 'eval "$(pyenv init -)"'
      - 'eval "$(pyenv virtualenv-init -)"'

install-pyenv-python:
  cmd.run:
    - name: pyenv install -v {{ target_python }}
    - require:
      - update-bashrc

set-default-python:
  cmd.run:
    - name: pyenv global {{ target_python }}
    - require:
      - install-pyenv-python
