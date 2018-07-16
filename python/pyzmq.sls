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

pyzmq:
  {%- if grains['os_family'] not in ('Arch', 'Windows') %}
  pkg.installed:
    - name: {{ 'g++' if grains.os_family == 'Debian' else 'gcc-c++' }}
  {%- endif %}

  pip.installed:
    - name: pyzmq{{salt.pillar.get('pyzmq:version', '')}}
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    - global_options:
      - fetch_libzmq
    - install_options:
      - --zmq=bundled
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
