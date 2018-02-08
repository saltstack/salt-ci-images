include:
  - cloud-test-configs.digital_ocean
  - cloud-test-configs.ec2
  - cloud-test-configs.azure
  - cloud-test-configs.joyent
  - cloud-test-configs.gce
  - cloud-test-configs.openstack

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
      - file: rackspace-key
