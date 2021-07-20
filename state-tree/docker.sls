{%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}
{%- set docker_pkg = 'docker' %}
{%- set os_codename = salt['grains.get']('oscodename', '') if salt['grains.get']('os_family', '') == 'Debian' %}
{%- set os_arch = salt['grains.get']('osarch', '') if salt['grains.get']('os_family', '') == 'Debian' %}
{%- set os_majorrelease = salt['grains.get']('osmajorrelease', '') if salt['grains.get']('os', '') in ('AlmaLinux', 'CentOS', 'CentOS Stream', 'Fedora') %}

{%- if on_docker == False %}
include:
  - busybox
{%- endif %}

{%- if grains['os'] == 'Amazon' or (grains['os_family'] == 'Debian' and grains['osarch'] in ('amd64', 'armhf', 'arm64')) %}
docker-prereqs:
  pkg.installed:
    - pkgs:
      {%- if grains['os_family'] == 'Debian' %}
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      {%- elif grains['os'] == 'Amazon' %}
      - amazon-linux-extras
      {%- endif %}
{%- endif %}

{%- if (grains['os_family'] == 'Debian' and grains['osarch'] in ('amd64', 'armhf', 'arm64')) or grains['os'] in ('AlmaLinux', 'CentOS', 'CentOS Stream', 'Fedora') %}
docker-repo:
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
    {%- elif grains['os'] in ('AlmaLinux', 'CentOS Stream', 'CentOS') and grains['osmajorrelease'] >= 7 %}
    - name: docker-ce-stable
    - baseurl: https://download.docker.com/linux/centos/{{ os_majorrelease }}/x86_64/stable
    - gpgkey: https://download.docker.com/linux/centos/gpg
    - gpgcheck: 1
    - enabled: 1
    {%- elif grains['os'] == 'Fedora' %}
    - name: docker-ce-stable
    - baseurl: https://download.docker.com/linux/fedora/{{ os_majorrelease }}/x86_64/stable
    - gpgkey: https://download.docker.com/linux/fedora/gpg
    - gpgcheck: 1
    - enabled: 1
    {%- endif %}
{%- endif %}

# Amazon Linux 2 installs docker from OS distro repos
{%- if grains['os'] == 'Amazon' %}
amazon-install-docker:
  cmd.run:
    - name: 'amazon-linux-extras install docker -y'
    - creates: /usr/bin/docker

{%- if on_docker == False %}
amazon-docker-service:
  service.running:
    - name: docker
    - require:
      - file: /usr/bin/busybox
{%- endif %}
{%- endif %}

# SUSE, Fedora, Photon, and more install Docker from OS distro repos
{%- if grains['os'] != 'Amazon' %}
docker:
  pkg.installed:
    - pkgs:
      {%- if (grains['os_family'] == 'Debian' and grains['osarch'] in ('amd64', 'armhf', 'arm64')) or grains['os'] in ('AlmaLinux', 'CentOS', 'CentOS Stream', 'Fedora') %}
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
{%- endif %}
