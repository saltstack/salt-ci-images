include:
  - python.pip

wmi:
  pip.installed:
    - name: WMI==1.4.9
    - require:
      - pip-install
