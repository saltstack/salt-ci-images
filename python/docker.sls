{%- if grains['os'] == 'Windows' %}
  {%- set docker = 'docker==2.7.0' %}
{%- else %}
  {%- set docker = 'docker==3.7.2' %}
{%- endif %}

include:
  - python.requests
{%- if grains['os'] != 'Windows' %}
  - python.pip
{%- endif %}

# Can't use "docker" as ID declaration, it's being used in salt://docker.sls
docker_py:
  pip.installed:
    - name: {{docker}}
    - require:
      - requests
{%- if grains['os'] != 'Windows' %}
      - cmd: pip-install
{%- endif %}
