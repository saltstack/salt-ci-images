{% if grains['os'] not in ('Windows') %}
include:
  - gcc
  - python.pip
{% endif %}

pycrypto:
  pip.installed:
    - name: pycrypto >= 2.6.1
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi.c7.saltstack.net/simple
    - extra_index_url: https://pypi.python.org/simple
{% if grains['os'] not in ('Windows') %}
    - require:
      - cmd: pip-install
      - pkg: gcc
{% endif %}
