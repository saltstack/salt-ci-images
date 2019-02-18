{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
  - python.headers
  - gcc
{% endif %}

{%- load_yaml as map %}
Debian:
  pkgs:
  - libldap2-dev
  - libsasl2-dev
  - libdpkg-perl
RedHat:
  pkgs:
  - openldap-devel
Suse:
  pkgs:
  - openldap2-devel
  - cyrus-sasl-devel
Arch:
  pkgs:
  - openldap
{%- endload %}
{%- set openldap = salt['grains.filter_by'](map, grain='os_family') %}

python-ldap:
  pip.installed:
    - name: python-ldap
    {%- if pillar.get('py3', False) %}
    - pre_releases: True
    {%- endif %}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
      - pkg: gcc
      - pkg: python-ldap
      {%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
      - pkg: python-dev
      {%- endif %}
  pkg.installed:
    - pkgs: {{openldap.pkgs}}
{% endif %}
