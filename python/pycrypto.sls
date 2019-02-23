{%- if grains['os'] not in ('Windows',) %}
include:
  - gcc
  - python.pip
{%- endif %}

pycrypto:
  pip.installed:
    - name: pycrypto >= 2.6.1
    {%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
      - pkg: gcc
    {%- endif %}

{%- if grains['os'] == 'Windows' %}
{%- set salt_dir = salt['config.get']('python_install_dir', 'c:\\salt').rstrip('\\') %}
{%- set scripts_dir = salt_dir | path_join('bin', 'Scripts') %}
{%- set site_packages = salt_dir | path_join('Lib', 'site-packages') %}
fix-pycrypto:
  file.replace:
    - name: "{{ (site_packages | path_join('Crypto', 'Random', 'OSRNG', 'nt.py')).replace('\\', '\\\\') }}"
    - pattern: '^import winrandom$'
    - repl: 'from Crypto.Random.OSRNG import winrandom'
    - require:
      - pycrypto
{%- endif %}
