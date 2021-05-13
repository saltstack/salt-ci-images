man:
  pkg.installed:
    - aggregate: true
    {%- if grains.os_family == 'Suse' %}
    - name: man
    {%- else %}
    - name: man-db
    {%- endif %}
