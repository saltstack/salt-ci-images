{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

keyring:
  pip.installed:
    - name: keyring==5.7.1
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - upgrade: True
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
      {%- if grains['os'] == 'OpenSUSE' %}
      - pip: setuptools-scm
      {% endif %}
{% endif %}
