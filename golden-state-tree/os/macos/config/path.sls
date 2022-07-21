fix-path-for-mac:
  file.append:
    - names:
      - /etc/pam.d/sshd:
        - text: 'session    optional       pam_env.so'
      - /etc/environment:
        - text: 'export
          PATH=/opt/salt/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/salt/bin:/usr/local/sbin:/Library/Frameworks/Python.framework/Versions/3.6/bin:/Library/Frameworks/Python.framework/Versions/2.7/bin'
      - /etc/profile:
        - text: 'export PATH=/opt/salt/bin:$PATH:/Library/Frameworks/Python.framework/Versions/3.6/bin:/Library/Frameworks/Python.framework/Versions/2.7/bin'
  environ.setenv:
    - name: PATH
    - value: '/opt/salt/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/salt/bin:/usr/local/sbin:$PATH'
    - update_minion: True
