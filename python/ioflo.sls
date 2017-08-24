{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

install_ioflo:
  pip.installed:
    - name: ioflo
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
