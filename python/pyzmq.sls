include:
  - gcc
  - python.pip

pyzmq:
  pip.installed:
    {%- if salt['config.get']('virtualenv_path', None) is not None %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - global-options:
      - fetch_libzmq
    - install-options:
      - --zmq=bundled
    - require:
      - cmd: python-pip
      - pkg: gcc
