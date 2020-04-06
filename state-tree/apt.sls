{%- if grains['os_family'] == 'Debian' %}
disable_auto_updates_on_debian_family:
  file.absent:
    - name: /etc/apt/apt.conf.d/20auto-upgrades
{%- endif %}

apt-utils:
  pkg.installed
