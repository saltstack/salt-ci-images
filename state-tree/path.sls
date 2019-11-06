{%- if grains['os'] == 'MacOS' %}
fix path for mac:
  file.append:
    - names:
      - /etc/pam.d/sshd:
        - text: 'session    optional       pam_env.so'
      - /etc/environment:
        - text: 'export PATH=/opt/salt/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/salt/bin:/usr/local/sbin'
      - /etc/profile:
        - text: 'export PATH=/opt/salt/bin:$PATH'
  environ.setenv:
    - name: PATH
    - value: '/opt/salt/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/salt/bin:/usr/local/sbin:$PATH'
    - update_minion: True

{%- elif grains['os'] != 'Windows' %}
append-usr-local-bin-to-path:
  file.append:
    - name: /root/.bash_profile
    - text: 'export PATH=/usr/local/bin:$PATH'
    - unless: 'echo $PATH | grep -q /usr/local/bin'
  environ.setenv:
    - name: PATH
    - value: '/usr/local/bin:{{ salt.cmd.run_stdout('echo $PATH', python_shell=True).strip() }}'
    - unless: 'echo $PATH | grep -q /usr/local/bin'
    - update_minion: True
{%- endif %}
