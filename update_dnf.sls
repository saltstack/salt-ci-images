{% set fedora = True if grains['os'] == 'Fedora' else False %}
{% set fedora22 = True if fedora and grains['osrelease'] == '22' else False %}
{% set fedora23 = True if fedora and grains['osrelease'] == '23' else False %}
{% set fedora24 = True if fedora and grains['osrelease'] == '24' else False %}
{% set dnf_version = salt['pkg.latest_version']('dnf') %}

{% if dnf_version == '1.1.10-3.fc24' %}
not_updating:
  cmd.run:
    - name: echo "not updatig dnf due to bug https://bugzilla.redhat.com/show_bug.cgi?id=1415441"
{% elif fedora23 or fedora24 %}
update_dnf:
  cmd.run:
    - name: 'dnf upgrade -y dnf'
{% endif %}
