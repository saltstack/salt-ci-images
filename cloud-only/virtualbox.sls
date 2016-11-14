{% from "cloud-only/virtualbox-map.jinja" import vbox with context %}
{% set os_family = grains.get('os_family', '') %}
{% set on_redhat = True if os_family == 'RedHat' else False %}
{% set on_deb = True if os_family == 'Debian' else False %}

{% if on_redhat %}
add_vbox_repo:
  file.managed:
    - name: /etc/yum.repos.d/vbox.repo
    - source: http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo
    - skip_verify: True

install_epel_repo:
  pkg.installed:
    - sources:
      - epel-release: {{ vbox.epel }}

install_deps:
  pkg.installed:
    - pkgs:
      {% for pkg in vbox.pkgdeps %}
        - {{ pkg }}
      {% endfor %}

{% elif on_deb %}
add_vbox_repo:
  file.managed:
    - name: /etc/apt/sources.list.d/vbox.list
    - contents:
        {{ vbox.vboxrepo }}

install_key:
  cmd.run:
    - name: 'wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -'

install_key2:
  cmd.run:
    - name: 'wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -'

{% endif %}

install_vbox:
  pkg.installed:
    - name: VirtualBox-5.1
    - refresh: True
