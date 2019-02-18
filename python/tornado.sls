{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

{% set on_py26 = True if grains.get('pythonexecutable', '').endswith('2.6') else False %}
{% set debian8 = grains.os == 'Debian' and grains.osmajorrelease|int == 8 %}

{%- if on_py26 or debian8 %}
  {%- set version = '==4.4.3' %}
{%- else %}
  {%- set version = salt.pillar.get('tornado:version', '<5.0.0') %}
{%- endif %}

tornado:
{%- if pillar.tornado is defined %}
  pip.tornado:
    - name: "{{version}}"
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
{%- else %}
  pip.installed:
    - name: "tornado{{version}}"
{%- endif %}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
