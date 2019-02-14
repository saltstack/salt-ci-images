{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

install_pytest:
  pip.installed:
    - name: pytest
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
