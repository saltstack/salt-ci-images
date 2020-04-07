ec2-key:
  file.managed:
    - name: {{ salt['pillar.get']('ec2:private_key') }}
    - contents_pillar: ec2-jenkins
    - user: {{ salt['pillar.get']('ec2:user') }}
    - group: {{ salt['pillar.get']('ec2:group') }}
    - mode: 600
    - show_changes: False
