include:
  - python.pip

unittest-xml-reporting:
  pip.installed:
    - name: git://github.com/s0undt3ch/unittest-xml-reporting.git#egg=unittest-xml-reporting
    - require:
      - cmd: python-pip
