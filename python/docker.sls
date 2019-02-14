{%- if grains['os'] == 'Windows' %}
  {%- set docker = 'docker==2.7.0' %}
{%- else %}
  {%- set docker = 'docker' %}
{%- endif %}

{%- if grains['os'] != 'Windows' %}
include:
  - python.pip
{%- endif %}

# Can't use "docker" as ID declaration, it's being used in salt://docker.sls
docker_py:
  pip.installed:
    - name: {{docker}}
    - bin_env: {{ salt.config.get('virtualenv_path', '') }}
{%- if grains['os'] != 'Windows' %}
    - require:
      - cmd: pip-install
{%- endif %}
