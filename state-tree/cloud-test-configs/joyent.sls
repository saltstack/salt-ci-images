joyent-key:
  file.managed:
    - name: /root/.ssh/joyent-jenkins
    - contents_pillar: joyent-jenkins
    - user: {{ salt['pillar.get']('joyent:ssh_user') }}
    - group: {{ salt['pillar.get']('joyent:group') }}
    - mode: 600
    - show_changes: False
