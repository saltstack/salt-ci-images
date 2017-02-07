{% if grains['os'] not in ('Windows') %}
include:
  - python.pip
{% endif %}

python-etcd:
  pip.installed:
    - name: 'python-etcd==0.4.2'
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
{% if grains['os'] not in ('Windows') %}
    - require:
      - cmd: pip-install 
{% endif %}

