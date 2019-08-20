{%- if 'RedHat' in grains.os_family %}
enable-timedated-daemon:
  service.enabled:
    - name: systemd-timedated

stop-chrony:
  service.dead:
    - name: chronyd

remove-chrony:
  pkg.purged:
    - name: chrony
{%- else %}
enable-timesyncd-daemon:
  service.enabled:
    - name: systemd-timesyncd

stop-chrony:
  service.dead:
    - name: chrony

remove-chrony:
  pkg.purged:
    - name: chrony
{%- endif %}

remove-drift-file:
  file.absent:
    - name: /var/lib/chrony/
    - require:
      - stop-chrony

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
