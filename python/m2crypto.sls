include:
  - gcc
  - swig
  - python.pip

m2crypto:
  pip.installed:
    {%- if salt['config.get']('virtualenv_path', None) is not None %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require:
      - cmd: python-pip
      - pkg: gcc
      - pkg: swig
