include:
  {%- if grains['os'] != 'Windows' %}
  - python.pip
  {%- endif %}
  - python.six

raet:
  pip.installed:
    - require:
    {%- if grains['os'] != 'Windows' %}
      - cmd: pip-install
    {%- endif %}
      - pip: six

