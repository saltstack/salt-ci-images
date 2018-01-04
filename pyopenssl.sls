{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
  - python.cffi
{% endif %}

pyopenssl:
  pip.installed:
    - name: pyOpenSSL
    - upgrade: True
    {%- if salt['config.get']('virtualenv_path', None) %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    {%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
    {%- if pillar.get('py3', False) %}
    - require_in:
      - pip: cffi
    {%- endif %}
    {%- endif %}
