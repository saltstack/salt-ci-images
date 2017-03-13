{%- if grains['os'] == 'CentOS' and grains['osrelease']|int == 7 %}
docker:
  pkg.installed:
    - pkgs:
      - docker
      - busybox
  service.running:
    - require:
      - pkg: docker
{%- endif %}
