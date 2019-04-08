{%- if not grains['osrelease'].startswith('15') %}
python-zypp:
  cmd.run:
    - name: zypper -n install python-zypp
{%- endif %}
