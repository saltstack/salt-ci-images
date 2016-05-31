{% set cent = True if grains['os'] == 'CentOS' else False %}
{% set cent6 = True if cent and grains['osmajorrelease'] == 6 %}
include:
  - python.pip

gitpython:
  pip.installed:
    {% if cent6 %}
    - name: 'gitpython==2.0.3'
    {% endif %}
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: pip-install 

