{% set fedora = True if grains['os'] == 'Fedora' else False %}
{% set fedora22 = True if fedora and grains['osrelease'] == '22' else False %}
{% set fedora23 = True if fedora and grains['osrelease'] == '23' else False %}

{% if fedora %}
versionlock:
  cmd.run:
    {% elif fedora22 %}
    - name: "dnf install -y 'dnf-command(versionlock)'"
    {% elif fedora23 %}
    - name: "dnf install -y python-dnf-plugins-extras-versionlock"
    {% endif %}
{% endif %}
