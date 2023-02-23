{%- set target_python = "3.10.10" %}
include:
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

pyenv-python:
  pyenv.installed:
    - name: {{ target_python }}
    - default: True
    - require:
      - install-dependencies
