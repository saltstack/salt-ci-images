include:
  - pip

unittest2:
  pip.installed:
    - require:
      - pkg: python-pip
    - mirrors:
      - http://g.pypi.python.org
      - http://c.pypi.python.org
      - http://pypi.crate.io
