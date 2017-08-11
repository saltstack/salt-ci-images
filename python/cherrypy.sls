{% if grains['os'] not in ('Windows') %}
include:
  - python.pip
{% endif %}

{% set on_py26 = True if grains.get('pythonexecutable', '').endswith('2.6') else False %}

cherrypy:
  pip.installed:
    {% if on_py26 %}
    {# CherryPy dropped Python 2.6 support in version 11.0.0 -#}
    - name: 'cherrypy < 11.0.0'
    {% endif %}
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    {%- if salt['config.get']('pip_target', None)  %}
    - target: {{ salt['config.get']('pip_target') }}
    {%- endif %}
{% if grains['os'] not in ('Windows') %}
    - require:
      - cmd: pip-install
{% endif %}


{% if on_py26 %}
# Install older versions of CherryPy deps that have dropped Python 2.6 support

# portend 1.8 is the last version which supports Python 2.6
portend:
  pip.installed:
    - name: 'portend == 1.8'
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require_in:
      - pip: cherrypy

# tempora 1.6.1 is the last version which supports Python 2.6
tempora:
  pip.installed:
    - name: 'tempora == 1.6.1'
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require_in:
      - pip: portend
{% endif %}
