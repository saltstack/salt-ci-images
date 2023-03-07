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
    - runas: {{ pillar["ssh_username"] }}
    - require:
      - curl
      - install-dependencies

install-pyenv-python:
  cmd.run:
    - name: pyenv install -v {{ target_python }}
    - runas: {{ pillar["ssh_username"] }}

set-default-python:
  cmd.run:
    - name: pyenv global {{ target_python }}
    - runas: {{ pillar["ssh_username"] }}
    - require:
      - install-pyenv-python
