include:
  - python.pip

unittest2:
  pip.installed:
    - require:
      - pkg: python-pip
    {%- if [int(i) for i in grains.get('saltversion').split('.') if i.isdigit()][:2] >= [0, 17] %}
    - mirrors:
      - http://g.pypi.python.org
      - http://c.pypi.python.org
      - http://pypi.crate.io
    {% endif %}
