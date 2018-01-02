{% set on_redhat_7 = True if grains.get('osmajorrelease', 0)|int == 7 else False %}
{%- load_yaml as rawmap %}
Ubuntu:
  package: glance
RedHat:
  package: openstack-glance
CentOS:
  package: openstack-glance
{%- endload %}
{%- set glance = salt['grains.filter_by'](rawmap, grain='os') %}

include:
  - openstack.repo

glance packages:
  pkg.latest:
    - force_yes: True
    - pkgs:
      - {{ glance.package }}
      {% if on_redhat_7 %}
      - python2-glanceclient
      {% else %}
      - python-glanceclient
      {% endif %}
