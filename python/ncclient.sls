include:
  - python.pip

# Newer versions of paramiko (2.2.0) require a minimum version of the
# PyNaCl lib of 1.0.1, which doesn't install correctly on some distros.
# This is pinned at 2.1.2 until the installation issues are resolved.
ncclient:
  pip.installed:
    - name: ncclient==0.6.4
    - require:
      - cmd: pip-install
