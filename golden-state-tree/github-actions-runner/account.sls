
create-actions-runner-account:
  user.present:
    - name: actions-runner
    - shell: /bin/bash
    - home: /home/actions-runner
    - empty_password: true
    - createhome: true
    - usergroup: true
    - optional_groups:
      {#-
          These groups get added to the user if the groups exist.
          The groups were collected from the golden images cloud-init configuration
          file /etc/cloud/cloud.cfg
      #}
      - adm
      - audio
      - cdrom
      - dialout
      - dip
      - docker
      - floppy
      - lxd
      - netdev
      - plugdev
      - sudo
      - systemd-journal
      - users
      - video
      - wheel
      {%- if grains['os'] == 'VMware Photon OS' %}
      {#- Let's also include the root's group in the account since Photon OS's
          images are commonly built to use root and not other system accounts #}
      - root
      {%- endif %}

actions-runner-sudoers-file:
  file.managed:
    - name: /etc/sudoers.d/actions-runner
    - mode: "0644"
    - contents:
      - actions-runner ALL=(ALL) NOPASSWD:ALL
