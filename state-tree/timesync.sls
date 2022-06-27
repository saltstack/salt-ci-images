{%- if grains['os_family'] == 'Debian' %}
  {%- if not grains['osmajorrelease'] in (9, 10, 18) %}
install-systemd-timesyncd:
  pkg.installed:
    - name: systemd-timesyncd
  {%- endif %}

enable-timesyncd-daemon:
  service.enabled:
    - name: systemd-timesyncd

stop-chrony:
  service.dead:
    - name: chrony

remove-chrony:
  pkg.purged:
    - name: chrony

remove-drift-file:
  file.absent:
    - name: /var/lib/chrony/
    - require:
      - stop-chrony
{%- endif %}

{%- if grains['os'] == 'Ubuntu' %}
install-tzdata:
  pkg.installed:
    - name: tzdata

symlink-timezone-file:
  file.symlink:
    - name: /etc/localtime
    - target: /usr/share/zoneinfo/Etc/UTC
{%- endif %}

{%- if grains['os'] == 'AlmaLinux' and grains['osmajorrelease'] >= 9 %}
install-tzdata:
  pkg.installed:
    - name: tzdata

symlink-timezone-file:
  file.symlink:
    - name: /etc/localtime
    - target: /usr/share/zoneinfo/UTC
{%- endif %}

set-time-zone:
  timezone.system:
    - name: Etc/UTC
    - utc: True
