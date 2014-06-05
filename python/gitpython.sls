include:
  - git
  - python.setuptools


gitpython:
  cmd:
    - run
    - cwd: /
    {% if grains['os'] == 'SmartOS' %}
    {#- Adapt to SmartOS's script directory #}
    - name: easy_install --script-dir=/opt/local/bin -U 'GitPython>=0.3.2rc1'
    {%- else %}
    - name: easy_install --script-dir=/usr/bin -U 'GitPython>=0.3.2rc1'
    {%- endif %}
    - require:
      - pkg: git
      - cmd: python-setuptools
