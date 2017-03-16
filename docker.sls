{%- if grains['os'] == 'CentOS' and grains['osrelease']|int == 7 %}
/usr/bin/busybox:
  file.managed:
    - source: http://repo.saltstack.com/dev/testing/redhat/7/x86_64/archive/busybox/1.26.2/busybox-x86_64
    - source_hash: 79b3c42078019db853f499852dac831afda935acf9df4c748c3bab914f1cf298
    - mode: 0755

docker:
  pkg.installed:
    - name: docker
  service.running:
    - require:
      - file: /usr/bin/busybox
      - pkg: docker
{%- endif %}
