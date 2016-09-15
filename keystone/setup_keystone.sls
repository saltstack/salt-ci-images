include:
  - .setup_db

setup keystone services:
  keystone.service_present:
    - name: keystone
    - description: OpenStack Identity
    - service_type: identity
    - connection_token: administrator
    - connection_endpoint: http://localhost:35357/v2.0

keystone endpoints:
  keystone.endpoint_present:
    - name: keystone
    - region: RegionOne
    - publicurl: http://localhost:5000/v2.0
    - internalurl: http://localhost:5000/v2.0
    - adminurl: http://localhost:35357/v2.0
    - connection_token: administrator
    - connection_endpoint: http://localhost:35357/v2.0

keystone projects:
  keystone.tenant_present:
    - names:
      - admin:
        - description: Admin Project
      - demo:
        - description: Demo Project
      - service:
        - description: Service Project
    - connection_token: administrator
    - connection_endpoint: http://localhost:35357/v2.0

keystone roles:
  keystone.role_present:
    - names:
      - admin
      - user
    - connection_token: administrator
    - connection_endpoint: http://localhost:35357/v2.0

keystone users:
  keystone.user_present:
    - names:
      - admin:
        - email: admin@example.com
        - password: adminpass
        - tenant: admin
        - roles:
            admin:
              - admin
      - demo:
        - email: demo@example.com
        - password: demopass
        - tenant: demo
        - roles:
            demo:
              - user
    - connection_token: administrator
    - connection_endpoint: http://localhost:35357/v2.0
