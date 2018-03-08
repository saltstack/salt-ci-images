fix path for mac:
  file.append:
    - names:
      - /etc/pam.d/sshd:
        - text: 'session    optional       pam_env.so'
      - /etc/environment:
        - text: 'export PATH=/opt/salt/bin/:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/salt/bin:/usr/local/sbin'
      - /etc/profile:
        - text: 'export PATH=/opt/salt/bin/:$PATH'
