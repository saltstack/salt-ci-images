{% set cent7 = True if grains['os'] == 'CentOS' and grains['osmajorrelease'] == '7' else False %}
{% set debian = True if grains['os_family'] == 'Debian' else False %}

{% set python = 'python3' %}
{% set get_pip = '{0} get-pip.py'.format(python) %}

{% if cent7 %}
  {% set python3_devel = 'python34-devel' %}
{% elif debian %}
  {% set python3_devel = 'python3-dev' %}
{% endif %}

{% set salttesting = 'git+https://github.com/saltstack/salt-testing@develop#egg=SaltTesting' %}

include:
  - python3
  - gcc

install-pip3:
  cmd.run:
    - name: curl -L 'https://bootstrap.pypa.io/get-pip.py' -o get-pip.py && {{ get_pip }} -U 'pip<8.1.2'
    - require:
      - pkg: install_python3

install-python3-dev:
  pkg.installed:
    - name: {{ python3_devel }}
    - require:
      - pkg: install_python3

install-python3-salt:
  cmd.run:
    - name: 'pip3 install git+https://github.com/saltstack/salt.git'
    - require:
      - pkg: install-python3-dev

install-pip3-packages:
  cmd.run:
    - name: 'pip3 install psutil setproctitle mock magicmock gitpython {{ salttesting }} pysqlcipher3 unittest2'
    - require:
      - cmd: install-pip3
      - cmd: install-python3-salt
      - pkg: install-python3-dev
      - cmd: unittest-xml-reporting-py3

unittest-xml-reporting-py3:
  pip.installed:
    - name: git+https://github.com/s0undt3ch/unittest-xml-reporting.git#egg=unittest-xml-reporting
    - update: True
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: install-pip3


install-coverage:
  cmd.run:
    - name: 'pip3 install coverage>=3.5.3'
    - require:
      - cmd: install-pip3


install-pytest:
  cmd.run:
    - name: 'pip3 install pytest pytest-tempdir pytest-helpers-namespace'
    - require:
      - cmd: install-pip3


install-pytest-catchlog:
  cmd.run:
    - name: 'pip3 install git+https://github.com/s0undt3ch/pytest-catchlog.git@features/full-logging#egg=Pytest-catchlog'
    - require:
      - cmd: install-pip3


install-pytest-salt:
  cmd.run:
    - name: 'pip3 install -U git+https://github.com/saltstack/pytest-salt.git@master#egg=pytest-salt'
    - require:
      - cmd: install-pip3
