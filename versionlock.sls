{% if salt['grains.get']('os', '') == 'Fedora' and grains['osmajorrelease']|int < 26 %}
include:
  - update_dnf

versionlock:
  cmd.run:
    - name: "dnf install -y python-dnf-plugins-extras-versionlock python3-dnf-plugins-extras-versionlock"
    - require:
      - cmd: update_dnf
{% endif %}
