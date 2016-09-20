include:
  - .setup_db

nova services:
  keystone.service_present:
    - name: nova 
    - description: OpenStack Compute
    - service_type: compute
    - connection_token: administrator
    - connection_endpoint: http://localhost:35357/v2.0

nova endpoints:
  keystone.endpoint_present:
    - name: nova
    - region: RegionOne
    - publicurl: 'http://localhost:8774/v2.1/%(tenant_id)s'
    - internalurl: 'http://localhost:8774/v2.1/%(tenant_id)s'
    - adminurl: 'http://localhost:8774/v2.1/%(tenant_id)s'
    - connection_token: administrator
    - connection_endpoint: http://localhost:35357/v2.0

nova users:
  keystone.user_present:
    - names:
      - nova:
        - email: nova@example.com
        - password: novapass
        - tenant: service
        - roles:
            service:
              - admin
    - connection_token: administrator
    - connection_endpoint: http://localhost:35357/v2.0
