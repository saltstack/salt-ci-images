{% set fedora = True if grains['os'] == 'Fedora' else False %}
{% set fedora22 = True if fedora and grains['osrelease'] == '22' else False %}
{% set fedora23 = True if fedora and grains['osrelease'] == '23' else False %}

{% if fedora23 %}
update_dnf:
  cmd.run:
    - name: 'dnf upgrade dnf'
{% endif %}
