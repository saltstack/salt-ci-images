{%- if grains['os_family'] == 'Windows' %}
  {%- set pip = 'py -3 -m pip' %}
{%- elif grains['os_family'] == 'FreeBSD' %}
  {%- set pip = 'pip-3.9' %}
{%- else %}
  {%- set pip = 'pip3' %}
{%- endif %}

pyyaml:
  cmd.run:
    - name: {{ pip }} install pyyaml==6.0.1
    - unless:
      {%- if grains['os_family'] == 'Windows' %}
      - py -3 -c "import yaml"
      {%- else %}
      - python3 -c "import yaml"
      {%- endif %}
