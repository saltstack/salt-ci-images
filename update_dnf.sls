{%- set dnf_version = salt['pkg.latest_version']('dnf') %}

{%- if dnf_version == '1.1.10-3.fc24' %}
not_updating:
  cmd.run:
    - name: echo "not updating dnf due to bug https://bugzilla.redhat.com/show_bug.cgi?id=1415441"
{%- else %}
update_dnf:
  cmd.run:
    - name: 'dnf upgrade -y dnf'
{%- endif %}
