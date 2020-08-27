libvirt-ssh-config:
  file.append:
    - name: /root/.ssh/config
    - text:
      - Include /root/.ssh/libvirt_config
libvirt-ssh-config-file:
  file.managed:
    - name: /root/.ssh/libvirt_config
    - contents: |
        Host {{ salt['pillar.get']('libvirt:ssh_host') }}
        IdentityFile /root/.ssh/libvirt_ssh_key
        UserKnownHostsFile /dev/null
        StrictHostKeyChecking no
    - show_changes: False
libvirt-key:
  file.managed:
    - name: /root/.ssh/libvirt_ssh_key
    - contents_pillar: libvirt:ssh_key
    - user: root
    - group: root
    - mode: 600
    - show_changes: False
