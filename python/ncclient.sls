include:
  - python.pip

# ncclient 0.6.5 fails to install, we should be able to remove this after that
# issue is resolved
ncclient:
  pip.installed:
    - name: ncclient==0.6.4
    - require:
      - cmd: pip-install
