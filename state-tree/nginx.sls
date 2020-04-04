nginx:
  pkg.installed:
    - aggregate: True

{%- if grains['os_family'] in ('Debian',) %}
{#- Debian based distributions always start services #}
disable-nginx-service:
  service.disabled:
    - name: nginx
{%- endif %}
