{% set distro = salt['grains.get']('oscodename', '')  %}
{% set os_family = salt['grains.get']('os_family', '') %}
{% set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}

{% if os_family == 'RedHat' and os_major_release == 7 %}
  {% set python3 = 'python34' %}
{% elif os_family == 'Arch' %}
  {% set python3 = 'python' %}
{% elif grains['os'] == 'Windows' %}
  {% set python3 = 'python3_x86' %}
{% else %}
  {% set python3 = 'python3' %}
{% endif %}

install_python3:
  pkg.installed:
    - name: {{ python3 }}
    - aggregate: True
