openldap:
  pkg.installed:
    - pkgs:
    {%- if grains['os_family'] == 'Debian' %}
      - libldap2-dev
      - libsasl2-dev
      - libdpkg-perl
    {%- elif grains['os_family'] == 'RedHat' and grains['os'] != 'VMware Photon OS' %}
      - openldap-devel
    {%- elif grains['os_family'] == 'FreeBSD' %}
      - openldap-client
      - openldap-server
    {%- elif grains['os_family'] == 'Suse' %}
      - openldap2-devel
      - cyrus-sasl-devel
    {%- elif grains['os_family'] == 'Arch' or grains['os'] == 'VMware Photon OS' %}
      - openldap
    {%- endif %}
