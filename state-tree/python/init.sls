{%- if grains['os_family'] in ('Arch', 'MacOS') or
       grains['osfinger'] in ('Amazon Linux-2', 'CentOS Linux-7', 'Debian-9', 'Ubuntu-16.04', 'Ubuntu-18.04', 'Leap-15', 'Fedora-30', 'Windows-2016Server', 'Windows-2019Server') %}
  {%- set install_python_2 = True %}
{%- else %}
  {%- set install_python_2 = False %}
{%- endif %}

include:
  - python3
  {%- if install_python_2 %}
  - python27
  {%- endif %}
  {%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
  {#- These distributions don't ship the develop headers separately #}
  - python.headers
  {%- endif %}
