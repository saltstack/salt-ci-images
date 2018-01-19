man:
  pkg.installed:
    {%- if grains.os_family == 'Suse' or (grains['os'] == 'CentOS' and grains['osmajorrelease']|int <= 6) %}
    - name: man
    {%- else %}
    - name: man-db
    {%- endif %}
