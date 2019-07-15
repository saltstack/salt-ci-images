# PyTest 4.6.x are the last Py2 and Py3 releases
{%- set pytest_pinning = '>=4.6.1,<4.7' %}

{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

install_pytest:
  pip.installed:
    - name: 'pytest {{ pytest_pinning }}'
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
