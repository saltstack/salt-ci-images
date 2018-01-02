# Arch Linux on some clouds has a default encoding of ASCII
# This is not typical in production, so set this to UTF-8 instead
#
# This will cause integration.shell.matcher.MatchTest.test_salt_documentation_arguments_not_assumed
# to fail if not set correctly.

{%- if grains['os'] in ('MacOS',) %}
mac_locale:
  file.blockreplace:
    - name: /etc/profile
    - marker_start: '#------ start locale zone ------'
    - marker_end: '#------ endlocale zone ------'
    - content: |
        export LANG=en_US.UTF-8
    - append_if_not_found: true
{%- else %}

{% set suse = True if grains['os_family'] == 'Suse' else False %}


{% if suse %}
suse_local:
  pkg.installed:
    - name: glibc-locale
{% elif grains.os_family == 'Debian' %}
deb_locale:
  pkg.installed:
    - pkgs:
      - locales
      - console-data
  {% if grains.get('init') == 'systemd' %}
      - dbus
  service.running:
    - name: dbus.socket
  {%- endif %}
{% endif %}

{% set arch = True if grains['os_family'] == 'Arch' else False %}
{% if arch %}
accept_LANG_sshd:
  file.append:
    - name: /etc/ssh/sshd_config
    - text: AcceptEnv LANG
  service.running:
    - name: sshd
    - listen:
      - file: accept_LANG_sshd
{% endif %}

us_locale:
  locale.present:
    - name: en_US.UTF-8

default_locale:
  locale.system:
    - name: en_US.UTF-8
    - require:
      - locale: us_locale

{%- endif %}
