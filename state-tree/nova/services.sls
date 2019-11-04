{%- load_yaml as rawmap %}
Ubuntu:
  services:
    controller:
      - nova-api
      - nova-consoleauth
      - nova-scheduler
      - nova-conductor
      - nova-novncproxy
    compute:
      - nova-compute
RedHat:
  services:
    controller:
      - openstack-nova-api
      - openstack-nova-consoleauth
      - openstack-nova-scheduler
      - openstack-nova-conductor
      - openstack-nova-novncproxy
    compute:
      - openstack-nova-compute
      - libvirtd
CentOS:
  services:
    controller:
      - openstack-nova-api
      - openstack-nova-consoleauth
      - openstack-nova-scheduler
      - openstack-nova-conductor
      - openstack-nova-novncproxy
    compute:
      - openstack-nova-compute
      - libvirtd
{%- endload %}
{%- set nova = salt['grains.filter_by'](rawmap, grain='os') %}

include:
  - .setup_keystone

start nova conroller services:
  service.running:
    - names: {{nova.services.controller}}
    - watch:
      - file: nova config

start nova compute services:
  service.running:
    - names: {{nova.services.compute}}
    - watch:
      - file: nova config
