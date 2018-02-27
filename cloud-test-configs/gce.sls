gce-key:
 file.managed:
   - name: /root/.ssh/gce-jenkins.json
   - contents_pillar: gce-jenkins
   - user: {{ salt['pillar.get']('gce:user') }}
   - group: {{ salt['pillar.get']('gce:group') }}
   - mode: {{ salt['pillar.get']('gce:mode') }}
   - show_changes: False
gce-ssh-key:
 file.managed:
   - name: /root/.ssh/gce_ssh_key
   - contents_pillar: gce-ssh-key
   - user: {{ salt['pillar.get']('gce:user') }}
   - group: {{ salt['pillar.get']('gce:group') }}
   - mode: {{ salt['pillar.get']('gce:mode') }}
   - show_changes: False
