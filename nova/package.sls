{% set on_redhat = True if grains['os_family'] == 'RedHat' else False %}

{%- load_yaml as rawmap %}
Ubuntu:
  packages:
    - nova-api
    - nova-conductor
    - nova-consoleauth
    - nova-novncproxy
    - nova-scheduler
    - nova-compute
    - python-novaclient
RedHat:
  packages:
    - openstack-nova-api
    - openstack-nova-conductor
    - openstack-nova-console
    - openstack-nova-novncproxy
    - openstack-nova-scheduler
    - openstack-nova-compute
    - python-novaclient
CentOS:
  packages:
    - openstack-nova-api
    - openstack-nova-conductor
    - openstack-nova-console
    - openstack-nova-novncproxy
    - openstack-nova-scheduler
    - openstack-nova-compute
    - python-novaclient
{%- endload %}
{%- set nova = salt['grains.filter_by'](rawmap, grain='os') %}

include:
  - openstack.repo

mask iscsid service for ubuntu 16.04:
  file.symlink:
    - name: /etc/systemd/system/iscsid.service
    - target: /dev/null
    - force: True

nova packages:
  pkg.latest:
    - force_yes: True
    - pkgs: {{ nova.packages }}

{% if on_redhat %}
python-psutils:
  pip.installed:
    - name: psutil==2.2.1
{% endif %}
