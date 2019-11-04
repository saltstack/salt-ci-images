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

openldap:
  pkg.installed:
    - pkgs: {{openldap.pkgs}}
