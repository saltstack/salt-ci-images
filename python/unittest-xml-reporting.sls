include:
  - python.pip

unittest-xml-reporting:
  pip.installed:
    - name: https://github.com/xmlrunner/unittest-xml-reporting.git#egg=unittest-xml-reporting
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: python-pip
