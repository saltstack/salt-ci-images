{%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}

{%- if on_docker == False %}
include:
  - download.busybox
{%- endif %}

amazon-linux-extras:
  pkg.installed

install-docker:
  cmd.run:
    - name: 'amazon-linux-extras install docker -y'
    - creates: /usr/bin/docker
    - require:
      - amazon-linux-extras

{%- if on_docker == False %}

amazon-docker-service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - /usr/bin/busybox
      - install-docker
{%- endif %}
