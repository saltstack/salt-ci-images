{%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}
{%- set docker_pkg = 'docker' %}
{%- set os_codename = salt['grains.get']('oscodename', '') if salt['grains.get']('os_family', '') == 'Debian' %}
{%- set os_arch = salt['grains.get']('osarch', '') if salt['grains.get']('os_family', '') == 'Debian' %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', '') %}

{%- if on_docker == False %}
include:
  - busybox
{%- endif %}

{%- if grains['os'] == 'Amazon' or (grains['os_family'] == 'Debian' and grains['osarch'] in ('amd64', 'armhf', 'arm64') and os_major_release != 11) %}
docker-prereqs:
  pkg.installed:
    - pkgs:
      {%- if grains['os_family'] == 'Debian' %}
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
      {%- elif grains['os'] == 'Amazon' %}
      - amazon-linux-extras
      {%- endif %}
{%- endif %}

# The following will not work in tiamat-generated, and otherwise isolated,
# Python envs of salt due to requiring system-level Python packages for
# pkgrepo to properly function:
# apt: https://gitlab.com/saltstack/open/salt-pkg/-/issues/38
# rpm: https://gitlab.com/saltstack/open/salt-pkg/-/issues/36
#
# Currently commented out until it is resolved, and Tiamat-generated salt builds
# are used in salt-jenkins
#{%- if (grains['os_family'] == 'Debian' and grains['osarch'] in ('amd64', 'armhf', 'arm64') and os_major_release != 11) or grains['os'] in ('AlmaLinux', 'CentOS', 'CentOS Stream', 'Fedora') %}
#docker-repo:
#  pkgrepo.managed:
#    - humanname: Docker Official
#    {%- if grains['os'] == 'Ubuntu' %}
#    - name: deb [arch={{ os_arch }}] https://download.docker.com/linux/ubuntu {{ os_codename }} stable
#    - key_url: https://download.docker.com/linux/ubuntu/gpg
#    - dist: {{ os_codename }}
#    - file: /etc/apt/sources.list.d/docker.list
#    {%- elif grains['os'] == 'Debian' %}
#    - name: deb [arch={{ os_arch }}] https://download.docker.com/linux/debian {{ os_codename }} stable
#    - key_url: https://download.docker.com/linux/debian/gpg
#    - dist: {{ os_codename }}
#    - file: /etc/apt/sources.list.d/docker.list
#    {%- elif grains['os'] in ('AlmaLinux', 'CentOS Stream', 'CentOS') and grains['osmajorrelease'] >= 7 %}
#    - name: docker-ce-stable
#    - baseurl: https://download.docker.com/linux/centos/{{ os_major_release }}/x86_64/stable
#    - gpgkey: https://download.docker.com/linux/centos/gpg
#    - gpgcheck: 1
#    - enabled: 1
#    {%- elif grains['os'] == 'Fedora' %}
#    - name: docker-ce-stable
#    - baseurl: https://download.docker.com/linux/fedora/{{ os_major_release }}/x86_64/stable
#    - gpgkey: https://download.docker.com/linux/fedora/gpg
#    - gpgcheck: 1
#    - enabled: 1
#    {%- endif %}
#{%- endif %}

# Workaround for pkgrepo bug
{%- if (grains['os_family'] == 'Debian' and os_arch in ('amd64', 'armhf', 'arm64') and os_major_release != 11) or grains['os'] in ('AlmaLinux', 'CentOS', 'CentOS Stream', 'Fedora') %}
docker-repo-workaround:
  cmd.run:
    {%- if grains['os'] == 'Ubuntu' %}
    - name:
      - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      - echo "deb [arch={{ os_arch }} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    {%- elif grains['os'] == 'Debian' %}
    - name:
      - curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      - echo "deb [arch={{ os_arch }} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    {%- elif grains['os'] in ('AlmaLinux', 'CentOS Stream', 'CentOS') and grains['osmajorrelease'] >= 7 %}
    - name: |
        yum install -y yum-utils
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    {%- elif grains['os'] == 'Fedora' %}
    - name: |
        dnf -y install dnf-plugins-core
        dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
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
      {%- if (grains['os_family'] == 'Debian' and grains['osarch'] in ('amd64', 'armhf', 'arm64') and os_major_release != 11) or grains['os'] in ('AlmaLinux', 'CentOS', 'CentOS Stream', 'Fedora') %}
      - docker-ce
      - docker-ce-cli
      - containerd.io
      {%- else %}
      - {{ docker_pkg }}
      {%- endif %}
    {%- if (grains['os_family'] == 'Debian' and grains['osarch'] in ('amd64', 'armhf', 'arm64') and os_major_release != 11) or grains['os'] in ('AlmaLinux', 'CentOS', 'CentOS Stream', 'Fedora') %}
    - require:
      - pkgrepo: docker-repo
    - aggregate: False
    {%- endif %}
  {%- if on_docker == False and (grains['os'] == 'Debian' and os_major_release != 11) %}
  service.running:
    - enable: True
    - require:
      - file: /usr/bin/busybox
      - pkg: docker
  {%- endif %}
{%- endif %}
