rackspace-key:
  file.managed:
    - name: {{ salt['pillar.get']('rackspace:ssh_key_file', '') }}
    - contents_pillar: jenkins-rackspace
    - user: {{ salt['pillar.get']('rackspace:ssh_user') }}
    - group: {{ salt['pillar.get']('rackspace:group') }}
    - mode: 600
    - show_changes: False
