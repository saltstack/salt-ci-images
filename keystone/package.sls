{%- load_yaml as rawmap %}
Ubuntu:
  package: keystone
  service: keystone
  apache: apache2
  apache_dir: /etc/apache2/sites-enabled/
  wsgi: libapache2-mod-wsgi
  server: apache2
RedHat:
  package: openstack-keystone
  service: openstack-keystone
  apache: httpd
  apache_dir: /etc/httpd/conf.d
  wsgi: mod_wsgi
  server: httpd
CentOS:
  package: openstack-keystone
  apache: httpd
  apache_dir: /etc/httpd/conf.d
  service: openstack-keystone
  wsgi: mod_wsgi
  server: httpd
{%- endload %}
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
    - reload_modules: True
    - require:
      - pkgrepo: openstack repo

  service.dead:
    - name: {{keystone.service}}

{%- if grains['os'] == 'Ubuntu' %}
  apache_module.enabled:
    - name: wsgi
    - watch_in:
      - service: {{keystone.apache}}
{%- endif %}

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
    - require:
      - pkg: keystone packages
    - watch_in:
      - service: {{keystone.apache}}
