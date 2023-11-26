{%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}
{%- if grains['osarch'] in ('armhf', 'arm64') %}
  {#- Don't install docker on arm platforms #}
  {% set install_docker = False %}
{%- else %}
  {% set install_docker = True %}
{%- endif %}

{%- if install_docker == True %}

  {%- if grains['os_family'] in ('Debian', 'RedHat') %}
    {%- if grains['os'] != 'VMware Photon OS' %}
      {%- if grains['os'] == 'Fedora' and grains['osmajorrelease']|int == 38 %}
        {#- There's no docker official packages for Fedora 38 yet as it's the unstable version of Fedora #}
        {%- set install_from_docker_repos = False %}
      {%- else %}
        {%- set install_from_docker_repos = True %}
      {%- endif %}
    {%- else %}
      {%- set install_from_docker_repos = False %}
    {%- endif %}
  {%- else %}
    {%- set install_from_docker_repos = False %}
  {%- endif %}

  {%- if on_docker == False %}
include:
  - download.busybox
  {%- endif %}

  {%- if grains['os_family'] == 'Debian' %}
docker-prereqs:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
  {%- endif %}

  {%- if install_from_docker_repos == True %}
docker-repo:
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
    {%- elif grains['os'] == 'Fedora' %}
    {#- Fedora must be addressed first because of the os_family logical check below #}
    - name: |
        dnf -y install dnf-plugins-core
        dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    {%- elif grains['os_family'] == 'RedHat' %}
    - name: |
        yum install -y yum-utils
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    {%- endif %}
  {%- endif %}

install-docker:
  pkg.installed:
    - refresh: True
    - aggregate: False
    - pkgs:
  {%- if install_from_docker_repos == True %}
      - docker-ce
      - docker-ce-cli
      - containerd.io
    - require:
      - docker-repo
  {%- else %}
    {%- if grains['os'] == 'Fedora' and grains['osmajorrelease']|int == 38 %}
      - moby-engine
    {%- else %}
      - docker
    {%- endif %}
  {%- endif %}

  {%- if grains['os_family'] != 'Debian' %}
    {%- if on_docker == False %}
reload-systemd-units:
  module.run:
    - name: service.systemctl_reload
    - order: 1

enable-docker-service:
  service.enabled:
    - name: docker
    - require:
      - install-docker
      - /usr/bin/busybox
      - reload-systemd-units
    {%- endif %}
  {%- endif %}
{%- endif %}
