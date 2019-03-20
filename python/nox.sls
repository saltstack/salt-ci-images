{%- set nox_version = '2018.10.17' %}

include:
  - python.pip

nox:
  pip.installed:
    - name: 'https://github.com/s0undt3ch/nox/archive/hotfix/py2.zip#egg=Nox=={{ nox_version }}'
    {%- if grains['os'] == 'Windows' %}
    - unless:
      - 'WHERE nox.exe'
    {%- else %}
    - onlyif:
      - '[ "$(which nox 2>/dev/null)" = "" ]'
    {%- endif %}
    - require:
      - pip-install
