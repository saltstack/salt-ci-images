{%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}
{%- set docker_pkg = 'docker.io' if salt['grains.get']('os', '') == 'Ubuntu' else 'docker' %}
{%- set os_codename = salt['grains.get']('oscodename', '') if salt['grains.get']('os', '') in ('Ubuntu', 'Debian') %}
{%- set os_arch = salt['grains.get']('osarch', '') if salt['grains.get']('os', '') in ('Ubuntu', 'Debian') %}

{%- if on_docker == False %}
include:
  - busybox
{%- endif %}

{%- if grains['os'] in ('Ubuntu', 'Debian') and grains['osarch'] in ('amd64', 'armhf', 'arm64') %}
docker-prereqs:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg

dockerepo:
  pkgrepo.managed:
    - humanname: Docker Official
    {%- if grains['os'] == 'Ubuntu' %}
    - name: deb [arch={{ os_arch }}] https://download.docker.com/linux/ubuntu {{ os_codename }} stable
    - key_url: https://download.docker.com/linux/ubuntu/gpg
    - dist: {{ os_codename }}
    {%- elif grains['os'] == 'Debian' %}
    - name: deb [arch={{ os_arch }}] https://download.docker.com/linux/debian {{ os_codename }} stable
    - key_url: https://download.docker.com/linux/debian/gpg
    - dist: {{ os_codename }}
    {%- endif %}
    - file: /etc/apt/sources.list.d/docker.list
{%- endif %}

docker:
  pkg.installed:
    - pkgs:
      {%- if grains['os'] in ('Ubuntu', 'Debian') and grains['osarch'] in ('amd64', 'armhf', 'arm64') %}
      - docker-ce
      - docker-ce-cli
      - containerd.io
      {%- else %}
      - {{ docker_pkg }}
      {%- endif %}
    - aggregate: True
{%- if on_docker == False %}
  service.running:
    - enable: True
    - require:
      - file: /usr/bin/busybox
      - pkg: docker
{%- endif %}
