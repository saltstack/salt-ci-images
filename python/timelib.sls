{%- if grains['os'] not in ('Windows',) %}
include:
  {%- if grains['os_family'] not in ('FreeBSD', 'Gentoo') %}
  - gcc
  {%- endif %}
  - python.pip
  {%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
  {#- These distributions don't ship the develop headers separately #}
  - python.headers
  {%- endif %}
{%- endif %}

{%- if grains['os_family'] in ('MacOS', ) %}
{#- Due to issue https://github.com/pediapress/timelib/issues/6 we need to use custom pkg for mac #}
{%- set timelib_dir = '/tmp/timelib/' %}
get-timelib-zip:
  archive.extracted:
    - name: {{ timelib_dir }}
    - source: https://artifactory.saltstack.net/artifactory/macos-files/timelib-0.2.4-mac.zip
    - source_hash: sha256=b9849442ba06f8e225d51ed860cff4ba51c95dbfadb720b878a9befb21dce134
    - archive_format: zip

timelib:
  cmd.run:
    - name: make install
    - cwd: {{ timelib_dir }}/timelib-0.2.4/
    - require:
        - archive: get-timelib-zip
{%- else %}
timelib:
  pip.installed:
    - name: timelib
{%- if grains['os'] not in ('Windows',) %}
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
{%- endif %}
{%- endif %}
