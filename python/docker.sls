include:
  - python.pip

# Can't use "docker" as ID declaration, it's being used in salt://docker.sls
docker_py:
  pip.installed:
    - name: docker
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require:
      - cmd: pip-install
