{% if grains['os'] not in ('Windows',) %}
include:
  {%- if grains['os_family'] not in ('FreeBSD', 'Gentoo') %}
  - gcc
  {%- endif %}
  - python.pip
  {%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
  {#- These distributions don't ship the develop headers separately #}
  - python.headers
  {% endif %}
{% endif %}

{%- if grains['os_family'] in ('MacOS', ) -%}
{#due to issue https://github.com/pediapress/timelib/issues/6 we need to use custom pkg for mac#}
{%- set timelib_dir = '/tmp/timelib/' -%}
get-timelib-zip:
  archive.extracted:
    - name: {{ timelib_dir }}
    - source: https://nexus.c7.saltstack.net/repository/salt-dev-raw/timelib-0.2.4-mac.zip
    - source_hash: sha512=0cb0b2f6a6249c38c8a5e043bcafde6f83f84d1d10f942d41dd8ff35f91df06b492811dbc896890a83c7feab17ba253c1517b93c9216a88e9e870e7465ac7a51
    - archive_format: zip

install-timelib:
  cmd.run:
    - name: make install
    - cwd: {{ timelib_dir }}/timelib-0.2.4/
    - require:
        - archive: get-timelib-zip
{% else %}
timelib:
  pip.installed:
    - name: timelib
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
{% if grains['os'] not in ('Windows',) %}
    - require:
      {%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
      {#- These distributions don't ship the develop headers separately #}
      - pkg: python-dev
      {%- endif %}
      {%- if grains['os_family'] not in ('FreeBSD', 'Gentoo') %}
        {#- FreeBSD always ships with gcc #}
      - pkg: gcc
      {%- endif %}
      - cmd: pip-install
{% endif %}
{% endif %}
