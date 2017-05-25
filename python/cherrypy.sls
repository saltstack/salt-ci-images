{% if grains['os'] not in ('Windows') %}
include:
  - python.pip
{% endif %}

{% set on_py26 = True if grains.get('pythonexecutable', '').endswith('2.6') else False %}

cherrypy:
  pip.installed:
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    {%- if salt['config.get']('pip_target', None)  %}
    - target: {{ salt['config.get']('pip_target') }}
    {%- endif %}
    - index_url: https://nexus.c7.saltstack.net/repository/salt-proxy/simple
    - extra_index_url: https://pypi.python.org/simple
{% if grains['os'] not in ('Windows') %}
    - require:
      - cmd: pip-install
{% endif %}

# Tempora 1.6.1 is the last version that supports PY 2.6, which we need
# for CentOS 6 on older release branches. Tempora is a dependency of
# Portend, which is a dependency of CherryPy.
{% if on_py26 %}
tempora:
  pip.installed:
    - name: tempora == 1.6.1
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require_in:
      - pip: cherrypy
{% endif %}