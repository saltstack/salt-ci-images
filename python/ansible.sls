{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}
{%- set exec = grains.get('pythonexecutable', '') %}
{%- set on_py27 = True if exec.endswith('2.7') else False %}
{%- set on_py35_or_newer = True if exec.split('.')[0] == 'python3' and exec[-1]|int >=5 else False %}

{%- if on_py27 or on_py35_or_newer %}
install_ansible:
  pip.installed:
    - name: ansible
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
{%- endif %}
