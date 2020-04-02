{%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}
{%- set docker_pkg = 'docker.io' if salt['grains.get']('os', '') == 'Ubuntu' else 'docker' %}

{%- if on_docker == False %}
include:
  - busybox
{%- endif %}

docker:
  pkg.installed:
    - name: {{ docker_pkg }}
    - aggregate: True
{%- if on_docker == False %}
  service.running:
    - enable: True
    - require:
      - file: /usr/bin/busybox
      - pkg: docker
{%- endif %}
