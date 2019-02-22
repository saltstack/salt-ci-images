{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
  - python.more-itertools
{%- endif %}

{%- set on_py26 = True if grains.get('pythonexecutable', '').endswith('2.6') else False %}

cherrypy:
  pip.installed:
    - name: 'cherrypy==17.3.0'
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
      - pip: more-itertools
{%- endif %}


{%- if on_py26 %}
# Install older versions of CherryPy deps that have dropped Python 2.6 support

# portend 1.8 is the last version which supports Python 2.6
portend:
  pip.installed:
    - name: 'portend == 1.8'
    - require_in:
      - pip: cherrypy

# tempora 1.6.1 is the last version which supports Python 2.6
tempora:
  pip.installed:
    - name: 'tempora == 1.6.1'
    - require_in:
      - pip: portend

# cheroot 5.11.0 is the last version which supports Python 2.6
cheroot:
  pip.installed:
    - name: 'cheroot==5.11.0'
    - require_in:
      - pip: cherrypy
{%- endif %}
