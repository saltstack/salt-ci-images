{% set distro = salt['grains.get']('oscodename', '')  %}
{% set os_family = salt['grains.get']('os_family', '') %}
{% set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}

{% if os_family == 'RedHat' and os_major_release == 7 %}
  {% set python3 = 'python34' %}
{% elif os_family == 'Arch' %}
  {% set python3 = 'python' %}
{% elif grains['os'] == 'Windows' %}
  {% set python3 = 'python3_x64' %}
{% else %}
  {% set python3 = 'python3' %}
{% endif %}
{% if os_family != 'Windows' %}
{% if os_family == 'MacOS' %}
install_python3:
  file.managed:
    - source: https://www.python.org/ftp/python/3.6.4/python-3.6.4-macosx10.6.pkg
    - name: /tmp/python-3.6.4-macosx10.6.pkg
    - user: root
    - group: wheel
    - skip_verify: True
  macpackage.installed:
    - name: /tmp/python-3.6.4-macosx10.6.pkg
    - reload_modules: True
install_certs:
  cmd.run:
    - name: /Applications/Python\ 3.6/Install\ Certificates.command
{% else %}

install_python3:
  pkg.installed:
    - name: {{ python3 }}
    - aggregate: True
{% endif %}
{% endif %}
