{% from '_python.sls' import python with context %}

{% if salt['cmd.run_stdout']('curl -sL -w "%{http_code}" https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -o /dev/null') != '200' %}
  {% set ez_setup_url = 'https://raw2.github.com/jaraco/setuptools/master/ez_setup.py' %}
{% else %}
  {% set ez_setup_url = 'https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py' %}
{% endif %}

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
    - name: curl -L {{ ez_setup_url }} | {{ python }}{%
        if grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == '5' %} - --insecure{% endif %}
    - require:
      - pkg: curl
      {%- if grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == '5' %}
      - pkg: python26
      {%- endif %}
