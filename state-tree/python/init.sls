{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}
{%- if grains['os'] == 'Debian' and os_major_release < 10 %}
  {%- set install_pyenv = True %}
{%- elif grains['os'] == 'Ubuntu' and os_major_release < 20 %}
  {%- set install_pyenv = True %}
{%- else %}
  {%- set install_pyenv = False %}
{%- endif %}

include:
{%- if install_pyenv %}
  - pyenv
{%- else %}
  - python3
  {%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
  {#- These distributions don't ship the develop headers separately #}
  - python.headers
  {%- endif %}
{%- endif %}
