{%- if grains['os_family'] == 'Debian' %}
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

set-time-zone:
  timezone.system:
    - name: Etc/UTC
    - utc: True
