include:
  - gcc
  - python.pip

jinja2:
  pip.installed:
    - name: jinja2==2.7
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi.c7.saltstack.net/simple
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: pip-install
      - pkg: gcc
