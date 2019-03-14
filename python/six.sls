{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}
{%- set os = salt['grains.get']('os', '') %}

{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

{#- Upgrading six on Fedora breaks urllib3 because of a symlink to six #}
{%- if grains['os'] not in ('Fedora',) %}
six:
  pip.installed:
    - upgrade: true
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
{%- endif %}
