digital-ocean-key:
  file.managed:
    - name: /root/.ssh/do-jenkins
    - contents_pillar: do-jenkins
    - user: {{ salt['pillar.get']('digital_ocean:user') }}
    - group: {{ salt['pillar.get']('digital_ocean:group') }}
    - mode: {{ salt['pillar.get']('digital_ocean:mode') }}
    - show_changes: False
