include:
  - python.pip

# ncclient 0.6.5 fails to install, we should be able to remove this after that
# issue is resolved
ncclient:
  pip.installed:
    - name: ncclient==0.6.4
    - require:
      - cmd: pip-install
# lxml doesn't support python3.4 anymore, pinning to last version that did
{%- if grains['osfinger'] in ['Debian-8'] %}
      - pip: ncclient_pip_dependencies

ncclient_pip_dependencies:
  pip.installed:
    - name: lxml==4.3.5
{%- endif %}
