{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

croniter:
  pip.installed:
    - name: "croniter>=0.3.0,!=0.3.22"
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
