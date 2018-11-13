{% if- pillar.get('py3', False) and grains['os_family'] == 'Suse' %}
  {% set pyzypp = 'python3-zypp-plugin' %}
{% else %}
  {% set pyzypp = 'python2-zypp-plugin' %}
{% endif %}

python-zypp:
  cmd.run:
    - name: zypper -n install {{ pyzypp }}
