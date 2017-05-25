{% set distro = salt['grains.get']('oscodename', '')  %}
{% set os_family = salt['grains.get']('os_family', '') %}
{% set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}

{% if os_family == 'RedHat' and os_major_release == 7 %}
  {% set python3 = 'python34' %}
{% elif os_family == 'Arch' %}
  {% set python3 = 'python' %}
{% else %}
  {% set python3 = 'python3' %}
{% endif %}

{% if os_family != 'Windows' %}
install_python3:
  pkg.installed:
    - name: {{ python3 }}
    - aggregate: True
{% endif %}
