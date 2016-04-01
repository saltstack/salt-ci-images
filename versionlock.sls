{% set fedora = True if grains['os'] == 'Fedora' else False %}
{% set fedora22 = True if fedora and grains['osrelease'] == '22' else False %}
{% set fedora23 = True if fedora and grains['osrelease'] == '23' else False %}

{% if fedora23 %}
include:
  - update_dnf
{% endif %}

{% if fedora %}
versionlock:
  cmd.run:
    {% if fedora22 %}
    - name: "dnf install -y 'dnf-command(versionlock)'"
    {% elif fedora23 %}
    - name: "dnf install -y python-dnf-plugins-extras-versionlock python3-dnf-plugins-extras-versionlock"
    - require:
      - cmd: update_dnf
    {% endif %}

{% endif %}
