# Arch Linux on some clouds has a default encoding of ASCII
# This is not typical in production, so set this to UTF-8 instead
#
# This will cause integration.shell.matcher.MatchTest.test_salt_documentation_arguments_not_assumed
# to fail if not set correctly.
{%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}
{%- set on_arch = grains['os_family'] == 'Arch' %}
{%- set on_suse = grains['os_family'] in ('Suse', 'SUSE') %}

{%- if grains['os'] in ('MacOS',) %}
mac_locale:
  file.blockreplace:
    - name: /etc/profile
    - marker_start: '#------ start locale zone ------'
    - marker_end: '#------ endlocale zone ------'
    - content: |
        export LANG=en_US.UTF-8
    - append_if_not_found: true

{%- elif grains['os'] in ('FreeBSD',) %}
/root/.bash_profile:
  file.managed:
    - user: root
    - group: wheel
    - mode: '0644'

freebsd_locale:
  file.blockreplace:
    - name: /root/.bash_profile
    - marker_start: '#------ start locale zone ------'
    - marker_end: '#------ endlocale zone ------'
    - content: |
        export LANG=en_US.UTF-8
    - append_if_not_found: true
{%- else %}

  {%- if on_suse %}
suse_local:
  pkg.installed:
    - pkgs:
      - glibc-locale
      - dbus-1

    {%- if not on_docker %}
  service.running:
    - name: dbus.socket
    - onlyif: systemctl daemon-reload
    {%- endif %}
  {%- elif grains.os_family == 'Debian' %}
deb_locale:
  file.touch:
    - name: /etc/default/keyboard  # ubuntu is stupid and this file has to exist for systemd-localed to be able to run
  pkg.installed:
    - pkgs:
      - locales
      - console-data
      - dbus
    {%- if grains.get('init') == 'systemd' %}
  service.running:
    - names:
      - dbus.socket
      - systemd-localed.service
    {%- endif %}
  {%- endif %}

  {%- if on_arch %}
accept_LANG_sshd:
  file.append:
    - name: /etc/ssh/sshd_config
    - text: AcceptEnv LANG
    {%- if not pillar.get('packer_golden_images_build', False) %}
  service.running:
    - name: sshd
    - listen:
      - file: accept_LANG_sshd
    {%- endif %}
  {%- endif %}

# Fedora and Centos 8
  {%- if grains['os_family'] == 'RedHat' and grains['osmajorrelease'] != 7 and grains['os'] != 'VMware Photon OS' %}
redhat_locale:
  pkg.installed:
    - name: glibc-langpack-en
  {%- endif %}

# Photon OS 3
  {%- if grains['os'] == 'VMware Photon OS' %}
photon_locale:
  pkg.installed:
    - name: glibc-lang
  {%- endif %}

us_locale:
  locale.present:
    - name: en_US.UTF-8

  {%- if grains['os_family'] not in ('FreeBSD',) %}
default_locale:
  locale.system:
    - name: en_US.UTF-8
    - require:
      - locale: us_locale
  {%- endif %}
{%- endif %}
