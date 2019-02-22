{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

pyinotify:
  pip.installed:
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
