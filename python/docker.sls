include:
  - python.pip
{%- if grains.os == 'Windows' %}
  {%- set docker = 'docker==2.7.0' %}
{%- else %}
  {%- set docker = 'docker' %}
{%- endif %}

# Can't use "docker" as ID declaration, it's being used in salt://docker.sls
docker_py:
  pip.installed:
    - name: {{docker}}
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - require:
      - cmd: pip-install
