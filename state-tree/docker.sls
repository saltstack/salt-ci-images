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
{%- endif %}

{%- if grains['os'] in ('Ubuntu', 'Debian') and grains['osarch'] in ('amd64', 'armhf', 'arm64') or grains['os'] in ('AlmaLinux', 'CentOS', 'CentOS Stream') %}
dockerepo:
  pkgrepo.managed:
    - humanname: Docker Official
    {%- if grains['os'] == 'Ubuntu' %}
    - name: deb [arch={{ os_arch }}] https://download.docker.com/linux/ubuntu {{ os_codename }} stable
    - key_url: https://download.docker.com/linux/ubuntu/gpg
    - dist: {{ os_codename }}
    - file: /etc/apt/sources.list.d/docker.list
    {%- elif grains['os'] == 'Debian' %}
    - name: deb [arch={{ os_arch }}] https://download.docker.com/linux/debian {{ os_codename }} stable
    - key_url: https://download.docker.com/linux/debian/gpg
    - dist: {{ os_codename }}
    - file: /etc/apt/sources.list.d/docker.list
    {%- elif grains['os'] in ('AlmaLinux', 'CentOS Stream') or grains['os'] == 'CentOS' and grains[osmajorrelease] == '8' %}
    - name: https://download.docker.com/linux/centos/8/x86_64/stable
    - key_url: https://download.docker.com/linux/centos/gpg
    - file: /etc/yum.repos.d/docker-ce.repo
    {%- elif grains['os'] == 'CentOS' and grains[osmajorrelease] == '7' %}
    - name: https://download.docker.com/linux/centos/7/x86_64/stable
    - key_url: https://download.docker.com/linux/centos/gpg
    - file: /etc/yum.repos.d/docker-ce.repo
    {%- endif %}
{%- endif %}

docker:
  pkg.installed:
    - pkgs:
      {%- if grains['os'] in ('Ubuntu', 'Debian') and grains['osarch'] in ('amd64', 'armhf', 'arm64') or grains['os'] in ('AlmaLinux', 'CentOS', 'CentOS Stream') %}
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
