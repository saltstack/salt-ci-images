{% if grains['os'] == 'Fedora' and grains['osrelease'] == '22' %}
versionlock:
  cmd.run:
    - name: "dnf install -y 'dnf-command(versionlock)'"
{% endif %}
