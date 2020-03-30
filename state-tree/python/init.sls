include:
  - python3
  {%- if grains['osfinger'] in ('Amazon Linux-2', 'CentOS Linux-7', 'Debian-9', 'Ubuntu-16.04', 'Ubuntu-18.04', 'Leap-15', 'Fedora-30', 'Windows-2016Server', 'Windows-2019Server') or grains['os_family'] in ('Arch', 'MacOS') %}
  - python27
  {%- endif %}
  {%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
  {#- These distributions don't ship the develop headers separately #}
  - python.headers
  {%- endif %}
