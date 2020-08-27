include:
  - .digital_ocean
  - .ec2
  - .azure
  - .joyent
  - .gce
  - .libvirt
  - .openstack
  - .vultr

ssh-directory:
  file.directory:
    - name: /root/.ssh
    - user: root
    - group: root
    - mode: 600
    - makedirs: True
    - require_in:
      - file: digital-ocean-key
      - file: ec2-key
      - file: azure-key
      - file: joyent-key
      - file: gce-key
      - file: libvirt-key
      - file: rackspace-key
      - file: vultr-key
