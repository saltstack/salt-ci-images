# We need:
  # python3
  # pip3
  # tornado mock magicmock salt salttesting from pip3
  # python34-devel
# We don't need to install the minion under python3 quite yet, but that would be best. This simply lets us run the test suite against python3

{% set arch = True if grains['os'] == 'Arch' else False %}
{% set cent7 = True if grains['os'] == 'CentOS' and grains['osmajorrelease'] == 7 else False %}

include:
  - pkg: python3

{% if arch %}
  {% set python = 'python' %}
{% else %}
  {% set python = 'python3' %}
{% endif %}

{% set get_pip = '{0} get-pip.py'.format(python) %}

install-pip3:
  - cmd.run:
    {% if arch %}
    - name: 'wget https://bootstrap.pypa.io/get-pip.py' && {{ get_pip }}
    {% else %}
    - name: curl -L 'https://bootstrap.pypa.io/get-pip.py' -o get-pip.py && {{ get_pip }}
    {% endif %}

install-pip3-packages:
  - cmd.run:
    - name: 'pip3 install salt salttesting mock magicmock'
    - require:
      - pkg: python3

{% if cent7 %}
install-python3-dev:
  - pkg.installed:
    - name: python34-devel
    - require:
      - pkg: python3
{% endif %}
