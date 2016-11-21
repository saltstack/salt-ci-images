{% set on_redhat_7 = True if grains.get('osmajorrelease', '') == '7' else False %}
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
    {% if on_redhat_7 %}
    - python2-novaclient
    {% else %}
    - python-novaclient
    {% endif %}
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
