{% if grains['os'] == 'openSUSE' %}
python-zypp:
  cmd.run:
    - name: zypper -n install python-libzypp
