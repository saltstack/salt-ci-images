{%- set include_paramiko = False %}
{%- if grains['os'] in ['Debian', 'Ubuntu'] %}
  {%- set include_paramiko = True %}
{%- endif %}

include:
  - python.pip
  {%- if include_paramiko %}
  - python.paramiko
  {%- endif %}
  - python.ncclient

{%- if grains['os'] in ['Ubuntu', 'Debian'] %}
pyez dependencies:
  pkg.installed:
    - pkgs:
      - libxslt1-dev
      - libssl-dev
      - libffi-dev
{%- elif grains['os'] in ['Fedora', 'CentOS'] %}
pyez dependencies:
  pkg.installed:
    - pkgs:
      - libxml2-devel
      - libxslt-devel
      - gcc
      - openssl-devel
      - libffi-devel
      - redhat-rpm-config
{%- elif grains['os'] == 'FreeBSD' %}
pyez dependencies:
  pkg.installed:
    - pkgs:
      - libxml2
      - libxslt
{%- endif %}

# lxml doesn't support python3.4 anymore, pinning to last version that did
{%- if grains['osfinger'] in ['CentOS Linux-7', 'Debian-8'] %}
junos-eznc_pip_dependencies:
  pip.installed:
    - name: lxml==4.3.5
{%- endif %}

junos-eznc:
  pip.installed:
    - require:
      - cmd: pip-install
      {%- if include_paramiko %}
      - pip: paramiko
      {%- endif %}
      - pip: ncclient
