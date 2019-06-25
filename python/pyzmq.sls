{%- if grains['os'] != 'Windows' %}
include:
{%- if grains['os_family'] not in ('FreeBSD', 'Gentoo', 'Windows') %}
  - gcc
{%- endif %}
  - python.pip
{%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS', 'Windows') %}
{#- These distributions don't ship the develop headers separately #}
  - python.headers
{%- endif %}
{%- endif %}

pyzmq:
  {%- if grains['os_family'] not in ('Arch', 'Windows', 'MacOS') %}
  pkg.installed:
    - name: {{ 'g++' if grains.os_family == 'Debian' else 'gcc-c++' }}
  {%- endif %}

  pip.installed:
    {%- if pillar.get('py3', False) and grains.get('os_family') == 'Suse' and grains.get('osrelease') == '42.3' %}
    - name: pyzmq==17.1.1
    {%- else %}
    - name: pyzmq{{salt.pillar.get('pyzmq:version', '')}}
    {%- endif %}
  {%- if grains['os_family'] in ('MacOS') %}
    - upgrade: True
  {%- endif %}
  {%- if grains['os_family'] not in ('MacOS') and '10.14' in grains['osrelease'] %}
    {%- if grains['os_family'] not in ('Suse') %}
    - global_options:
      - fetch_libzmq
    {%- endif %}
    - install_options:
      - --zmq=bundled
  {%- endif %}
    {%- if grains['os'] != 'Windows' %}
    - require:
      - cmd: pip-install
      {%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS', 'Windows') %}
      {#- These distributions don't ship the develop headers separately #}
      - pkg: python-dev
      {%- endif %}
      {%- if grains['os_family'] not in ('FreeBSD', 'Gentoo', 'Windows') %}
        {#- FreeBSD always ships with gcc #}
      - pkg: gcc
      {%- endif %}
    {%- endif %}
