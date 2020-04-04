nginx:
  pkg.installed:
    - aggregate: True

disable-nginx-service:
  service.disabled:
    - name: nginx
