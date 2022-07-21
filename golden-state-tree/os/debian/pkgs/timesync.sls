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
