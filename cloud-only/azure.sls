include:
  - python.pip

azure:
  pip.installed:
    {%- if (grains['os'] == 'CentOS') %}
    - name: azure==0.8.3
    {%- else %}
    - name: azure
    {%- endif %}
    {%- if salt['config.get']('virtualenv_path', None) %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require:
      - cmd: pip-install
