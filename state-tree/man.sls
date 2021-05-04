man:
  pkg.installed:
    - aggregate: true
    {%- if grains.os_family == 'Suse' or (grains['os'] in ('CentOS', 'CentOS Stream') and grains['osmajorrelease']|int <= 6) %}
    - name: man
    {%- else %}
    - name: man-db
    {%- endif %}
