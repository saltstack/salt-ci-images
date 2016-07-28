{% set fedora = True if grains['os'] == 'Fedora' else False %}
{% set fedora22 = True if fedora and grains['osrelease'] == '22' else False %}
{% set fedora23 = True if fedora and grains['osrelease'] == '23' else False %}
{% set fedora24 = True if fedora and grains['osrelease'] == '24' else False %}

{% if fedora23 or fedora24 %}
include:
  - update_dnf
{% endif %}

{% if fedora %}
versionlock:
  cmd.run:
    {% if fedora22 %}
    - name: "dnf install -y 'dnf-command(versionlock)'"
    {% elif fedora23 or fedora24 %}
    - name: "dnf install -y python-dnf-plugins-extras-versionlock python3-dnf-plugins-extras-versionlock"
    - require:
      - cmd: update_dnf
    {% endif %}

{% endif %}
