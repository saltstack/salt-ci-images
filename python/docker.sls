{%- if grains['os'] == 'Windows' %}
  {%- set docker = 'docker==2.7.0' %}
{%- elif grains['os'] == 'CentOS' and salt['grains.get']('osmajorrelease', 0) == 7 %}
  {%- set docker = 'docker<4.0.0' %}
{%- else %}
  {%- set docker = 'docker' %}
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
