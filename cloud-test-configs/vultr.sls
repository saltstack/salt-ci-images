vultr-key:
  file.managed:
    - name: /root/.ssh/jenkins-vultr
    - contents_pillar: jenkins-vultr
    - user: {{ salt['pillar.get']('vultr:user') }}
    - group: {{ salt['pillar.get']('vultr:group') }}
    - mode: 600
    - show_changes: False
