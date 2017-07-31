{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

unittest-xml-reporting:
  pip.installed:
    {%- if grains['os_family'] == 'RedHat' and grains['osmajorrelease']|int <= 6 %}
    - name: git+https://github.com/s0undt3ch/unittest-xml-reporting.git#egg=unittest-xml-reporting
    {%- endif %}
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi.c7.saltstack.net/simple
    - extra_index_url: https://pypi.python.org/simple
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
