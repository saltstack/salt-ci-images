include:
  - .setup_db

glance services:
  keystone.service_present:
    - name: glance 
    - description: OpenStack Image
    - service_type: image
    - connection_token: administrator
    - connection_endpoint: http://localhost:35357/v2.0

glance endpoints:
  keystone.endpoint_present:
    - name: glance
    - region: RegionOne
    - publicurl: http://localhost:9292
    - internalurl: http://localhost:9292
    - adminurl: http://localhost:9292
    - connection_token: administrator
    - connection_endpoint: http://localhost:35357/v2.0

glance users:
  keystone.user_present:
    - names:
      - glance:
        - email: glance@example.com
        - password: glancepass
        - tenant: service
        - roles:
            service:
              - admin
    - connection_token: administrator
    - connection_endpoint: http://localhost:35357/v2.0
