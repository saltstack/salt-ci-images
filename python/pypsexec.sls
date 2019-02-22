{%- if grains['os'] in ('CentOS',) %}
include:
  - python.pip

pypsexec:
  pip.installed:
    - require:
      - cmd: pip-install
{%- endif %}
