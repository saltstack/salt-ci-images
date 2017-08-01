{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

gitpython:
  pip.installed:
    {%- if grains['os'] == 'CentOS' and grains['osmajorrelease']|int <= 6 %}
    # GitPython 2.0.9 introduced a dep on salttesting.case which is not
    # available in Python 2.6
    - name: 'GitPython < 2.0.9'
    {%- else %}
    - name: GitPython
    {%- endif %}
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
{% if grains['os'] not in ('Windows') %}
    - require:
      - cmd: pip-install
{% endif %}
