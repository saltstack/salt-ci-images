{%- set get_pip_dir = salt.temp.dir(prefix='get-pip-') %}
{%- set get_pip_path = get_pip_dir | path_join('get-pip.py') %}

download-get-pip:
  file.managed:
    - name: {{ get_pip_path }}
    - source: https://github.com/pypa/get-pip/raw/b3d0f6c0faa8e02322efb00715f8460965eb5d5f/get-pip.py
    - skip_verify: true

pip-install:
  cmd.run:
    - name: {{ grains['pythonexecutable'] }} {{ get_pip_path }} 'pip<=9.0.1'
    - cwd: /
    - reload_modules: True
    - onlyif:
      - '[ "$(which pip{{ grains['pythonversion'][0] }} 2>/dev/null)" = "" ]'
    - require:
      - download-get-pip

remove-get-pip:
  file.absent:
    - name: {{ get_pip_dir}}
    - require:
      - pip-install

gitpython:
  pip.installed:
    - name: 'GitPython == 2.0.9'
    - require:
      - pip-install
