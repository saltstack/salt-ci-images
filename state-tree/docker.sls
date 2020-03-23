{%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}
{%- set docker_pkg = 'docker.io' if salt['grains.get']('os', '') == 'Ubuntu' else 'docker' %}

busybox:
  pkg.installed
    - aggregate: True

docker:
  pkg.installed:
    - name: {{ docker_pkg }}
    - aggregate: True
{%- if on_docker == False %}
  service.running:
    - enable: True
    - require:
      - pkg: busybox
      - pkg: docker
{%- endif %}
