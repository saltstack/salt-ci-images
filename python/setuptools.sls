{% from '_python.sls' import python with context %}

include:
  - curl
  {%- if grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == '5' %}
  - python26
  {%- endif %}

python-setuptools:
  {#
    I'm installing setuptools this way since I want the most up to date version
    for all distributions. This avoids trying to handle different versions
    accepting different CLI options
  -#}
  cmd:
    - run
    - cwd: /
    - name: curl -L https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py | {{ python }}
    - require:
      - pkg: curl
      {%- if grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == '5' %}
      - pkg: python26
      {%- endif %}
