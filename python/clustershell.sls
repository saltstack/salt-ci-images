include:
  - python.pip

clustershell:
  pip.installed:
    - name: clustershell
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require:
      - cmd: pip-install
