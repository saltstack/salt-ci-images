include:
  - python.pip

{%- if grains['os'] == 'Fedora' %}
python-gnupg:
  pkg.removed
{%- endif %}

gnupg:
  pip.installed:
    - name: python-gnupg
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - require:
      {%- if grains['os'] == 'Fedora' %}
      - pkg: python-gnupg
      {%- endif %}
      - cmd: python-pip
