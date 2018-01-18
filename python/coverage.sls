{% set coverage_version = 'coverage==3.7.1' %}

{% if pillar.get('new_coverage', False) %}
  {% set coverage_version = 'coverage' %}
{% elif pillar.get('py3', False) and grains['os'] in ('Arch', 'Ubuntu') %}
  {% set coverage_version = 'coverage==4.4.1' %}
{% endif %}

{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

coverage:
  pip.installed:
    - name: {{ coverage_version }}
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
