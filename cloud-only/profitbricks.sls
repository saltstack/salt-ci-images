include:
  - python.pip

profitbricks:
  pip.installed:
    - name: profitbricks
    {%- if salt['config.get']('virtualenv_path', None) %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require:
      - cmd: pip-install
