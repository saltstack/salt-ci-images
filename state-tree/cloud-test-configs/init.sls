include:
  - .ssh_directory

{%- set config_path = '%s/tests/integration/files/conf/cloud.providers.d/'|format(salt.pillar.get('testing_dir', '/testing')) %}
{%- set profile_config_path = '%s/tests/integration/files/conf/cloud.profiles.d/'|format(salt.pillar.get('testing_dir', '/testing')) %}

azure-provider:
  file.managed:
    - name: {{ config_path }}azurearm.conf
    - contents: |
        azurearm-config:
          driver: azurearm
          subscription_id: {{ salt['pillar.get']('azure:subscription_id', '') }}
          cleanup_disks: True
          cleanup_interfaces: True
          cleanup_vhds: True
          cleanup_services: True
          minion:
            master_type: str
          tenant: '{{ salt['pillar.get']('azure:tenant', '') }}'
          client_id: '{{ salt['pillar.get']('azure:client_id', '') }}'
          secret: '{{ salt['pillar.get']('azure:secret', '') }}'
          location: westus
          allocate_public_ip: True
          network_resource_group: saltstack
          network: saltstack-vnet
          subnet: default
          resource_group: saltstack
    - show_changes: False
    - require:
      - file: ssh-directory

azure-profile:
  file.managed:
    - name: {{ profile_config_path }}azure.conf
    - contents: |
        azure-test:
          provider: azurearm-config
          image: Canonical|UbuntuServer|18.04-LTS|18.04.201804262
          size: Standard_D1
          slot: production
          ssh_username: {{ salt['pillar.get']('azure:ssh_username', '') }}
          ssh_password: {{ salt['pillar.get']('azure:ssh_password', '') }}
          script_args: '-P'
    - show_changes: False
    - require:
      - file: ssh-directory

digital-ocean-provider:
  file.managed:
    - name: {{ config_path }}digitalocean.conf
    - contents: |
        digitalocean-config:
          driver: digitalocean
          personal_access_token: {{ salt['pillar.get']('digital_ocean:personal_access_token', '') }}
          ssh_key_file: {{ salt['pillar.get']('digital_ocean:ssh_key_file', '') }}
          ssh_key_name: {{ salt['pillar.get']('digital_ocean:ssh_key_name', '') }}
          location: New York 1
          minion:
            master_type: str
          known_hosts_file: /dev/null
    - show_changes: False
    - require:
      - file: ssh-directory

ec2-provider:
  file.managed:
    - name: {{ config_path }}ec2.conf
    - contents: |
        ec2-config:
          driver: ec2
          id: {{ salt['pillar.get']('ec2:id', '') }}
          key: {{ salt['pillar.get']('ec2:key', '') }}
          keyname: {{ salt['pillar.get']('ec2:keyname', '') }}
          securitygroupname: {{ salt['pillar.get']('ec2:securitygroup', '') | json }}
          subnetid: {{ salt['pillar.get']('ec2:subnetid', '') }}
          ssh_interface: {{ salt['pillar.get']('ec2:ssh_interface', '') }}
          private_key: {{ salt['pillar.get']('ec2:private_key', '') }}
          location: {{ salt['pillar.get']('ec2:location', '') }}
          del_root_vol_on_destroy: {{ salt['pillar.get']('ec2:del_root_vol_on_destroy', '') }}
          minion:
            master_type: str
          known_hosts_file: /dev/null
    - show_changes: False
    - require:
      - file: ssh-directory

ec2-profile:
  file.managed:
    - name: {{ profile_config_path }}ec2.conf
    - contents: |
        ec2-test:
          provider: ec2-config
          image: {{ salt['pillar.get']('ec2:ami-centos7', '') }}
          size: {{ salt['pillar.get']('ec2:size', '') }}
          ssh_username: {{ salt['pillar.get']('ec2:user-centos7', '') }}
          script_args: '-P'
          tag: {'created-by': 'cloud-tests'}
        ec2-win2012r2-test:
          provider: ec2-config
          size: {{ salt['pillar.get']('ec2:size', '') }}
          image: {{ salt['pillar.get']('ec2:ami-win2012r2', '') }}
          smb_port: 445
          win_installer: ''
          win_username: {{ salt['pillar.get']('ec2:user-windows', '') }}
          win_password: auto
          userdata_file: ''
          userdata_template: False
          use_winrm: True
          winrm_verify_ssl: False
          deploy: True
          tag: {'created-by': 'cloud-tests'}
        ec2-win2016-test:
          provider: ec2-config
          size: {{ salt['pillar.get']('ec2:size', '') }}
          image: {{ salt['pillar.get']('ec2:ami-win2016', '') }}
          smb_port: 445
          win_installer: ''
          win_username: {{ salt['pillar.get']('ec2:user-windows', '') }}
          win_password: auto
          userdata_file: ''
          userdata_template: False
          use_winrm: True
          winrm_verify_ssl: False
          deploy: True
          tag: {'created-by': 'cloud-tests'}
    - show_changes: False
    - require:
      - file: ssh-directory

gogrid-provider:
  file.managed:
    - name: {{ config_path }}gogrid.conf
    - contents: |
        gogrid-config:
          driver: gogrid
          apikey: {{ salt['pillar.get']('gogrid:apikey', '') }}
          sharedsecret: {{ salt['pillar.get']('gogrid:sharedsecret', '') }}
          minion:
            master_type: str
          known_hosts_file: /dev/null
    - show_changes: False

gce-provider:
  file.managed:
    - name: {{ config_path }}gce.conf
    - contents: |
        gce-config:
           project: {{ salt['pillar.get']('gce:project') }}
           service_account_email_address: {{ salt['pillar.get']('gce:email') }}
           service_account_private_key: {{ salt['pillar.get']('gce:private_key') }}
           ssh_keyfile: /root/.ssh/gce_ssh_key
           minion:
             master_type: str
           driver: gce
           known_hosts_file: /dev/null
    - show_changes: False
joyent-provider:
  file.managed:
    - name: {{ config_path }}joyent.conf
    - contents: |
        joyent-config:
          driver: joyent
          user: {{ salt['pillar.get']('joyent:user', '') }}
          password: {{ salt['pillar.get']('joyent:password', '') }}
          private_key: {{ salt['pillar.get']('joyent:private_key', '') }}
          keyname: {{ salt['pillar.get']('joyent:keyname', '') }}
          location: {{ salt['pillar.get']('joyent:location', '') }}
          ssh_username: ubuntu
          minion:
            master_type: str
          known_hosts_file: /dev/null
    - show_changes: False

libvirt-provider:
  file.managed:
    - name: {{ config_path }}libvirt.conf
    - contents: |
        libvirt-config:
          driver: libvirt
          url: {{ salt['pillar.get']('libvirt:url') }}
          minion:
            master_type: str
          known_hosts_file: /dev/null
    - show_changes: False

libvirt-profile:
  file.managed:
    - name: {{ profile_config_path }}libvirt.conf
    - contents: |
        libvirt-test:
          provider: libvirt-config
          base_domain: {{ salt['pillar.get']('libvirt:base_domain') }}
          ssh_username: {{ salt['pillar.get']('libvirt:ssh_username') }}
          password: {{ salt['pillar.get']('libvirt:password') }}
    - show_changes: False

linode-provider:
  file.managed:
    - name: {{ config_path }}linode.conf
    - contents: |
        linode-config:
          apikey: {{ salt['pillar.get']('linode:apikey', '') }}
          password: {{ salt['pillar.get']('linode:password', '') }}
          driver: linode
          minion:
            master_type: str
          known_hosts_file: /dev/null
        linode-config-v4:
          apikey: {{ salt['pillar.get']('linode:apikey-v4', '') }}
          password: {{ salt['pillar.get']('linode:password', '') }}
          driver: linode
          api_version: v4
          minion:
            master_type: str
          known_hosts_file: /dev/null
    - show_changes: False

linode-profile:
  file.managed:
    - name: {{ profile_config_path }}linode.conf
    - contents: |
        linode-test:
          provider: linode-config
          size: Linode 2GB
          image: Ubuntu 20.04 LTS
          location: Fremont, CA, USA
        linode-test-v4:
          provider: linode-config-v4
          size: g6-standard-1
          image: linode/ubuntu20.04
          location: us-west
    - show_changes: False

{#- "<=2017.7" #}
rackspace-provider:
  file.managed:
    - name: {{ config_path}}rackspace.conf
    - contents: |
        rackspace-config:
          identity_url: 'https://identity.api.rackspacecloud.com/v2.0/tokens'
          compute_name: cloudServersOpenStack
          protocol: ipv4
          compute_region: DFW
          user: {{ salt['pillar.get']('rackspace:user', '') }}
          tenant: {{ salt['pillar.get']('rackspace:tenant', '') }}
          apikey: {{ salt['pillar.get']('rackspace:apikey', '') }}
          driver: openstack
          minion:
            master_type: str
          known_hosts_file: /dev/null
    - show_changes: False

{#- ">=oxygen" #}
openstack-provider:
  file.managed:
    - name: {{ config_path}}openstack.conf
    - contents: |
        openstack-config:
          driver: openstack
          profile: rackspace
          ssh_key_name: {{ salt['pillar.get']('rackspace:ssh_key_name', '') }}
          ssh_key_file: {{ salt['pillar.get']('rackspace:ssh_key_file', '') }}
          auth:
            username: {{ salt['pillar.get']('rackspace:user', '') }}
            api_key: {{ salt['pillar.get']('rackspace:apikey', '') }}
          region_name: ORD
          minion:
            master_type: str
          auth_type: rackspace_apikey
    - show_changes: False

vmware-provider:
  file.managed:
    - name: {{ config_path }}vmware.conf
    - contents: |
        vmware-config:
          driver: vmware
          user: {{ salt['pillar.get']('vmware:user', '') }}
          password: {{ salt['pillar.get']('vmware:password', '') }}
          url: {{ salt['pillar.get']('vmware:url', '') }}
          protocol: 'https'
          port: 443
          known_hosts_file: /dev/null
    - show_changes: False

vmware-profile:
  file.managed:
    - name: {{ profile_config_path }}vmware.conf
    - contents: |
        vmware-test:
          provider: vmware-config
          clonefrom: {{ salt['pillar.get']('vmware:clonefrom', '') }}
          num_cpus: 1
          memory: 2GB
          devices:
            disk:
              Hard disk 1:
                size: 30
              Hard disk 2:
                size: 5
                datastore: {{ salt['pillar.get']('vmware:datastore_disk', '') }}
          cluster: {{ salt['pillar.get']('vmware:cluster', '') }}
          datastore: {{ salt['pillar.get']('vmware:datastore', '') }}
          datacenter: {{ salt['pillar.get']('vmware:datacenter', '') }}
          host: {{ salt['pillar.get']('vmware:host', '') }}
          ssh_username: {{ salt['pillar.get']('vmware:ssh_username', '') }}
          password: {{ salt['pillar.get']('vmware:ssh_password', '') }}
    - show_changes: False

vultr-provider:
  file.managed:
    - name: {{ config_path }}vultr.conf
    - contents: |
        vultr-config:
          driver: vultr
          ssh_key_file: '/root/.ssh/jenkins-vultr'
          ssh_key_name: jenkins-vultr
          api_key: {{ salt['pillar.get']('vultr:api_key', '') }}
          location: {{ salt['pillar.get']('vultr:location', '') }}
          minion:
            master_type: str
          known_hosts_file: /dev/null
    - show_changes: False

vultr-profile:
  file.managed:
    - name: {{ profile_config_path }}vultr.conf
    - contents: |
        vultr-test:
          provider: vultr-config
          size: 2048 MB RAM,64 GB SSD,2.00 TB BW
          image: CentOS 7 x64
          enable_private_network: False
          location: New Jersey
    - show_changes: False
