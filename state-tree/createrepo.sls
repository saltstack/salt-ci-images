{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}
{%- if os_family == "RedHat" and os_major_release >= 8 %}
  {%- set createrepo = "createrepo_c" %}
{%- else %}
  {%- set createrepo = "createrepo" %}
{% endif %}
createrepo:
  pkg.installed:
    - name: {{ createrepo }}
    - aggregate: True
