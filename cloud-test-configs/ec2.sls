ec2-key:
  file.managed:
    - name: /root/.ssh/ec2-jenkins.pem
    - contents_pillar: ec2-jenkins
    - user: {{ salt['pillar.get']('ec2:user') }}
    - group: {{ salt['pillar.get']('ec2:group') }}
    - mode: {{ salt['pillar.get']('ec2:mode') }}
    - show_changes: False
