{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

pytest-tempdir:
  pip.installed:
    - name: pytest-tempdir
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
