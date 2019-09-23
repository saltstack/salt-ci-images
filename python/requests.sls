include:
  - python.pip
  - python.chardet

{%- if grains.get('pythonversion')[:2] < [3, 5] %}
  {%- set requests = 'requests<2.22.0'%}
{%- else %}
  {%- set requests = 'requests'%}
{%- endif %}

requests:
  pip.installed:
    - name: '{{ requests }}'
    - ignore_installed: true
    - require:
      - pip-install
      - chardet
