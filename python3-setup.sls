{% set arch = True if grains['os'] == 'Arch' else False %}
{% set cent7 = True if grains['os'] == 'CentOS' and grains['osmajorrelease'] == 7 else False %}

include:
  - python3

{% if arch %}
  {% set python = 'python' %}
{% else %}
  {% set python = 'python3' %}
{% endif %}

{% set get_pip = '{0} get-pip.py'.format(python) %}

install-pip3:
  cmd.run:
    {% if arch %}
    - name: wget 'https://bootstrap.pypa.io/get-pip.py' && {{ get_pip }} -U 'pip<8.1.2'
    {% else %}
    - name: curl -L 'https://bootstrap.pypa.io/get-pip.py' -o get-pip.py && {{ get_pip }} -U 'pip<8.1.2'
    {% endif %}
    - require:
      - pkg: install_python3

install-pip3-packages:
  cmd.run:
    - name: 'pip3 install salt mock magicmock salttesting'
    - require:
      - cmd: install-pip3

install-coverage:
  cmd.run:
    - name: 'pip3 install coverage>=3.5.3'
    - require:
      - cmd: install-pip3

{% if cent7 %}
install-python3-dev:
  pkg.installed:
    - name: python34-devel
    - require:
      - pkg: install_python3
{% endif %}
