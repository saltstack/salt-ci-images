include:
  - python.pytest
  {%- if grains['os'] not in ('Windows',) %}
  - python.pip
  {%- endif %}

pytest-salt:
  pip.installed:
    - name: pytest-salt
    - require:
      - pytest
      {%- if grains['os'] not in ('Windows',) %}
      - cmd: pip-install
      {%- endif %}
