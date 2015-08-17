include:
  - python.pip

keyring:
  pip.installed:
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - upgrade: True
    - require:
      - cmd: pip-install
      {%- if grains['os'] == 'OpenSUSE' %}
      - pip: setuptools-scm
      {% endif %}
