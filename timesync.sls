{%- if grains['os_family'] == 'Debian' %}
disable-timesyncd-daemon:
  service.enabled:
    - name: systemd-timesyncd

stop-chrony:
  service.stop:
    - name: chrony

remove-chrony:
  pkg.purged:
    - name: chrony

remove-drift-file:
  file.absent:
    - name: /var/lib/chrony/
    - require:
      - cmd: stop-chrony
{%- endif %}
