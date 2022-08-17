set-time-zone:
  {%- if grains['os'] in ("Arch", "CentOS Stream") %}
  cmd.run:
    - name: timedatectl set-timezone Etc/UTC
  {%- else %}
  timezone.system:
    - name: Etc/UTC
    - utc: True
  {%- endif %}
