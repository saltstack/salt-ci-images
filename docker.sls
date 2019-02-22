{%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}
{%- set docker_pkg = 'docker.io' if salt['grains.get']('os', '') == 'Ubuntu' else 'docker' %}

/usr/bin/busybox:
  file.managed:
    - source: http://repo.saltstack.com/dev/testing/redhat/7/x86_64/archive/busybox/1.26.2/busybox-x86_64
    - source_hash: sha256=79b3c42078019db853f499852dac831afda935acf9df4c748c3bab914f1cf298
    - mode: 0755

docker:
  pkg.installed:
    - name: {{ docker_pkg }}
    - aggregate: True
{%- if on_docker == False %}
  service.running:
    - require:
      - file: /usr/bin/busybox
      - pkg: docker
{%- endif %}
