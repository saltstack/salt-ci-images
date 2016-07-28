{% set fedora = True if grains['os'] == 'Fedora' else False %}
{% set fedora24 = True if fedora and grains['osrelease'] == '24' else False %}
include:
  - python.pip

setproctitle:
  pip.installed:
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: pip-install
      {%- if fedora24 %}
      - pkg: redhat-rpm-config
      {% endif %}
