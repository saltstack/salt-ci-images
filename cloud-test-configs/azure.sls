azure-key:
  file.managed:
    - name: /root/.ssh/azure-jenkins.pem
    - contents_pillar: azure-jenkins
    - user: {{ salt['pillar.get']('azure:user') }}
    - group: {{ salt['pillar.get']('azure:group') }}
    - mode: {{ salt['pillar.get']('azure:mode') }}
    - show_changes: False
