include:
  - gcc
  - swig
  - python.pip

m2crypto:
  pip.installed:
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require:
      - cmd: pip-install
      - pkg: gcc
      - pkg: swig
