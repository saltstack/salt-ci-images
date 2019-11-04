{%- if salt['grains.get']('os', '') == 'Fedora' %}
include:
  - update_dnf

versionlock:
  cmd.run:
    {%- if salt.grains.get('osmajorrelease')|int < 26 %}
    - name: "dnf install -y python-dnf-plugins-extras-versionlock python3-dnf-plugins-extras-versionlock"
    {%- elif salt.grains.get('osmajorrelease')|int >= 26 and salt.grains.get('osmajorrelease')|int < 30 %}
    - name: "dnf install -y python2-dnf-plugins-extras-versionlock python3-dnf-plugins-extras-versionlock"
    {%- else %}
    - name: "dnf install -y python3-dnf-plugins-extras-versionlock"
    {%- endif %}
    - require:
      - cmd: update_dnf
{%- endif %}
