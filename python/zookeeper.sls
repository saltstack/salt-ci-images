{# dockerd is required for the zookeeper test #}
include:
  - docker
  - python.pip

install kazoo:
  pip.installed:
    - name: kazoo
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://nexus.c7.saltstack.net/repository/salt-proxy/simple
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: pip-install
