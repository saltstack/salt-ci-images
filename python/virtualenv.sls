include:
  - python.pip

virtualenv:
  pip.installed:
    - require:
      - cmd: python-pip
    {%- if grains.get('saltversion').split('.')[:2] >= ['0', '17'] %}
    - mirrors:
      - http://g.pypi.python.org
      - http://c.pypi.python.org
      - http://pypi.crate.io
    {% endif %}
