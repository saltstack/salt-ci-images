#
# Currently there are no Docker provided packages available for CentOS Stream 9, so we skip all of this.
#
{%- if grains['os'] == 'CentOS Stream' and grains['osmajorrelease'] >= 9 %}
{% set install_docker = False %}
{%- else %}
{% set install_docker = True %}
{%- endif %}

{%- if install_docker == True %}
{%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}
{%- set install_from_docker_repos = True if (grains['os'] == 'Ubuntu' and grains['osarch'] in ('amd64', 'armhf', 'arm64')) or (grains['os_family'] == 'Debian' and grains['osarch'] in ('amd64', 'armhf', 'arm64') and grains['osmajorrelease'] <= 11) or grains['os'] in ('AlmaLinux', 'CentOS', 'CentOS Stream', 'Fedora') else False %}

{%- if on_docker == False %}
include:
  - busybox
{%- endif %}

{%- if grains['os'] == 'Amazon' or ((grains['os'] == 'Ubuntu' and grains['osarch'] in ('amd64', 'armhf', 'arm64')) or grains['os_family'] == 'Debian' and grains['osarch'] in ('amd64', 'armhf', 'arm64') and grains['osmajorrelease'] <= 11) %}
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
#{%- if install_from_docker_repos == True %}
#docker-repo:
#  pkgrepo.managed:
#    - humanname: Docker Official
#  {%- if grains['os'] == 'Ubuntu' %}
#    - name: deb [arch={{ grains['osarch'] }}] https://download.docker.com/linux/ubuntu {{ grains['oscodename'] }} stable
#    - key_url: https://download.docker.com/linux/ubuntu/gpg
#    - dist: {{ grains['oscodename'] }}
#    - file: /etc/apt/sources.list.d/docker.list
#  {%- elif grains['os'] == 'Debian' %}
#    - name: deb [arch={{ grains['osarch'] }}] https://download.docker.com/linux/debian {{ grains['oscodename'] }} stable
#    - key_url: https://download.docker.com/linux/debian/gpg
#    - dist: {{ grains['oscodename'] }}
#    - file: /etc/apt/sources.list.d/docker.list
#  {%- elif grains['os'] in ('AlmaLinux', 'CentOS Stream', 'CentOS') and grains['osmajorrelease'] >= 7 %}
#    - name: docker-ce-stable
#    - baseurl: https://download.docker.com/linux/centos/{{ grains['osmajorrelease'] }}/x86_64/stable
#    - gpgkey: https://download.docker.com/linux/centos/gpg
#    - gpgcheck: 1
#    - enabled: 1
#  {%- elif grains['os'] == 'Fedora' %}
#    - name: docker-ce-stable
#    - baseurl: https://download.docker.com/linux/fedora/{{ grains['osmajorrelease'] }}/x86_64/stable
#    - gpgkey: https://download.docker.com/linux/fedora/gpg
#    - gpgcheck: 1
#    - enabled: 1
#  {%- endif %}
#{%- endif %}

# Workaround for pkgrepo bug
{%- if install_from_docker_repos == True %}
docker-repo-workaround:
  cmd.run:
  {%- if grains['os'] == 'Ubuntu' %}
    - name: |
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch={{ grains['osarch'] }} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    - require:
      - docker-prereqs
  {%- elif grains['os'] == 'Debian' %}
    - name: |
        curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch={{ grains['osarch'] }} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    - require:
      - docker-prereqs
  {%- elif grains['os'] in ('AlmaLinux', 'CentOS Stream', 'CentOS') and grains['osmajorrelease'] >= 7 %}
    - name: |
        yum install -y yum-utils
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  {%- elif grains['os'] == 'Fedora' %}
    - name: |
        dnf -y install dnf-plugins-core
        dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  {%- elif grains['os'] == 'SUSE' %}
    - name: |
        zypper addrepo https://download.opensuse.org/repositories/security:SELinux/SLE_{{ grains['osrelease_info'][0] }}_SP{{ grains['osrelease_info'][1] }}/security:SELinux.repo
        zypper addrepo https://download.docker.com/linux/sles/docker-ce.repo
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
    - enable: True
    - name: docker
    - enable: True
    - require:
      - file: /usr/bin/busybox
  {%- endif %}
{%- endif %}

# SUSE, Fedora, Photon, and more install Docker from OS distro repos
{%- if grains['os'] != 'Amazon' %}
docker:
  pkg.installed:
    - refresh: True
    - pkgs:
  {%- if install_from_docker_repos == True %}
      - docker-ce
      - docker-ce-cli
      - containerd.io
  {%- else %}
      - docker
  {%- endif %}
  {%- if install_from_docker_repos == True %}
    - require:
      - cmd: docker-repo-workaround
    - aggregate: False
  {%- endif %}
  {%- if on_docker == False %}
  service.running:
    - enable: True
    - require:
      - file: /usr/bin/busybox
      - pkg: docker
  {%- endif %}
{%- endif %}
{%- endif %}
