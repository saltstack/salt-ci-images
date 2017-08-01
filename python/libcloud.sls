{% if grains['os'] not in ('Windows') %}
include:
  - python.pip
{% endif %}

apache-libcloud:
  pip.installed:
    - name: 'apache-libcloud==1.0.0'
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
{% if grains['os'] not in ('Windows') %}
    - require:
      - cmd: pip-install
{% endif %}
