{%- load_yaml as rawmap %}
Ubuntu:
  services:
    - openstack-glance-api
    - openstack-glance-registry
RedHat:
  services:
    - openstack-glance-api
    - openstack-glance-registry
CentOS:
  services:
    - openstack-glance-api
    - openstack-glance-registry
{%- endload %}
{%- set glance = salt['grains.filter_by'](rawmap, grain='os') %}

include:
  - .package

glance config:
  file.managed:
    - makedirs: True
    - names:
      - /etc/glance/glance-api.conf:
        - contents: |
            [database]
            connection = sqlite:////var/lib/glance/glance.sqlite
            [keystone_authtoken]
            auth_uri = http://localhost:5000/v2.0
            auth_url = http://localhost:35357/v2.0
            memcached_servers = localhost:11211
            auth_type = password
            project_name = service
            username = glance
            password = glancepass

            [paste_deploy]
            flavor = keystone

            [glance_store]
            stores = file,http
            default_store = file
            filesystem_store_datadir = /var/lib/glance/images/
      - /etc/glance/glance-registry.conf:
        - contents: |
            [database]
            connection = sqlite:////var/lib/glance/glance.sqlite

            [keystone_authtoken]
            auth_uri = http://localhost:5000/v2.0
            auth_url = http://localhost:35357/v2.0
            memcached_servers = localhost:11211
            auth_type = password
            project_name = service
            username = glance
            password = glancepass

            [paste_deploy]
            flavor = keystone

  service.running:
    - names: {{glance.services}}
    - watch:
      - file: glance config
