
{%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}
{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os = salt['grains.get']('os', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}
nginx:
  pkg.installed:
    - aggregate: False

{%- if os_family == 'Debian' and os_major_release != 9 and (os != "Ubuntu" and on_docker == False) %}
{#- Debian based distributions always start services #}
{#- DOesn't run in Ubuntu docker containers #}
disable-nginx-service:
  service.disabled:
    - name: nginx
{%- endif %}
