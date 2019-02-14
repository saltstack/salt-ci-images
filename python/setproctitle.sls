{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

install_setproctitle:
  pip.installed:
    - name: setproctitle
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
