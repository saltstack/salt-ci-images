include:
  - gcc
  - python.pip

pyzmq:
  pip.installed:
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - global-options:
      - fetch_libzmq
    - install-options:
      - --zmq=bundled
    - require:
      - cmd: pip-install
      - pkg: gcc
