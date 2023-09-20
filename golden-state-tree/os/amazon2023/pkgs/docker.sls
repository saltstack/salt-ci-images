{%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}

{%- if on_docker == False %}
include:
  - download.busybox
{%- endif %}

install-docker:
  pkg.installed:
    - name: docker
    - creates: /usr/bin/docker

{%- if on_docker == False %}
amazon-docker-service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - /usr/bin/busybox
      - install-docker
{%- endif %}
