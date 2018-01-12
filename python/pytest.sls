{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

{% set on_py26 = True if grains.get('pythonexecutable', '').endswith('2.6') else False %}

{%- if on_py26 %}
py:
  pip.installed:
    - name: py==1.4.34
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require:
      - cmd: pip-install
{%- endif %}

pytest:
  pip.installed:
    {%- if on_py26 %}
    - name: pytest==3.2.5
    {%- else %}
    - name: pytest
    {%- endif %}
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
