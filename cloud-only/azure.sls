include:
  - python.pip

azure:
  pip.installed:
    {%- if (grains['os'] == 'CentOS') %}
    - name: azure==1.0.2
    {%- else %}
    - name: azure
    {%- endif %}
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    - require:
      - cmd: pip-install
