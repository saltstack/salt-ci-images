nginx:
  pkg.installed

{%- if grains["os_family"] == 'Debian' %}
{#- Debian based distributions always start services #}
disable-nginx-service:
  service.disabled:
    - name: nginx
{%- endif %}
