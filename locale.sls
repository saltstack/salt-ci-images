# Arch Linux on some clouds has a default encoding of ASCII
# This is not typical in production, so set this to UTF-8 instead
#
# This will cause  integration.shell.matcher.MatchTest.test_salt_documentation_arguments_not_assumed
# to fail if not set correctly.

{% set suse = True if grains['os_family'] == 'Suse' else False %}
{% set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}

{% if suse %}
suse_local:
  pkg.installed:
    - name: glibc-locale
{% elif grains.os_family == 'Debian' and on_docker %}
deb_locale:
  pkg.installed:
    - pkgs:
      - locales
      - console-data
      - dbus
  service.running:
    - name: dbus.socket
{% endif %}

us_locale:
  locale.present:
    - name: en_US.UTF-8

default_locale:
  locale.system:
    - name: en_US.UTF-8
    - require:
      - locale: us_locale
