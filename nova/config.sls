include:
  - .package

nova config:
  file.managed:
    - makedirs: True
    - names:
      - /etc/nova/nova.conf:
        - contents: |
            [DEFAULT]
            enabled_apis = osapi_compute,metadata
            rpc_backend = rabbit
            auth_strategy = keystone
            my_ip = 127.0.0.1
            use_neutron = True
            firewall_driver = nova.virt.firewall.NoopFirewallDriver
            keys_path = /var/lib/nova/keys
            [api_database]
            connection = sqlite:////var/lib/nova/nova_api.sqlite
            [database]
            connection = sqlite:////var/lib/nova/nova.sqlite
            [oslo_messaging_rabbit]
            rabbit_host = localhost
            rabbit_userid = nova
            rabbit_password = novapass
            [keystone_authtoken]
            auth_uri = http://localhost:5000/v2.0
            auth_url = http://localhost:35357/v2.0
            memcached_servers = controller:11211
            auth_type = password
            project_name = service
            username = nova
            password = novapass
            [vnc]
            enabled = True
            vncserver_listen = 0.0.0.0
            vncserver_proxyclient_address = $my_ip
            novncproxy_base_url = http://127.0.0.1:6080/vnc_auto.html
            [glance]
            api_servers = http://localhost:9292
            [oslo_concurrency]
            lock_path = /var/lib/nova/tmp
            [libvirt]
            virt_type = qemu
