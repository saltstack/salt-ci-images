 {%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}

/usr/bin/busybox:
  file.managed:
    - source: http://repo.saltstack.com/dev/testing/redhat/7/x86_64/archive/busybox/1.26.2/busybox-x86_64
    - source_hash: sha256=79b3c42078019db853f499852dac831afda935acf9df4c748c3bab914f1cf298
    - mode: 0755

docker:
  pkg.installed:
    - aggregate: True
{%- if on_docker == False %}
  service.running:
    - enable: True
    - require:
      - file: /usr/bin/busybox
      - pkg: docker
{%- endif %}
