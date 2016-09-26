{% from "keystone/defaults.yaml" import rawmap with context %}
{%- set keystone = salt['grains.filter_by'](rawmap, grain='os') %}

include:
  - apache
  - openstack.repo

keystone packages:
  pkg.latest:
    - force_yes: True
    - pkgs:
      - {{ keystone.package }}
      - {{ keystone.wsgi }}
      - {{ keystone.apache }}
      - python-keystoneclient

  service.dead:
    - name: {{keystone.service}}

  file.managed:
    - name: {{keystone.apache_dir}}/keystone.conf
    - contents: |
        ServerName controller
        Listen 5000
        Listen 35357

        <VirtualHost *:5000>
            WSGIDaemonProcess keystone-public processes=1 threads=1 user=keystone group=keystone display-name=%{GROUP}
            WSGIProcessGroup keystone-public
            WSGIScriptAlias / /usr/bin/keystone-wsgi-public
            WSGIApplicationGroup %{GLOBAL}
            WSGIPassAuthorization On
            ErrorLogFormat "%{cu}t %M"
            ErrorLog /var/log/{{keystone.apache}}/keystone-error.log
            CustomLog /var/log/{{keystone.apache}}/keystone-access.log combined

            <Directory /usr/bin>
                Require all granted
            </Directory>
        </VirtualHost>

        <VirtualHost *:35357>
            WSGIDaemonProcess keystone-admin processes=1 threads=1 user=keystone group=keystone display-name=%{GROUP}
            WSGIProcessGroup keystone-admin
            WSGIScriptAlias / /usr/bin/keystone-wsgi-admin
            WSGIApplicationGroup %{GLOBAL}
            WSGIPassAuthorization On
            ErrorLogFormat "%{cu}t %M"
            ErrorLog /var/log/{{keystone.apache}}/keystone-error.log
            CustomLog /var/log/{{keystone.apache}}/keystone-access.log combined

            <Directory /usr/bin>
                Require all granted
            </Directory>
        </VirtualHost>
    - listen_in:
      - service: {{keystone.apache}}

{%- if grains['os'] == 'Ubuntu' %}
  apache_module.enabled:
    - name: wsgi
    - listen_in:
      - service: {{keystone.apache}}
{%- endif %}
