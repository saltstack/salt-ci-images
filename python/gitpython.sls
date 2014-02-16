include:
  - git
  - python.setuptools


gitpython:
  cmd:
    - run
    - cwd: /
    {% if grains['os'] == 'SmartOS' %}
    {#- Adapt to SmartOS's script directory #}
    - name: easy_install --script-dir=/opt/local/bin -U gitpython
    {%- else %}
    - name: easy_install --script-dir=/usr/bin -U gitpython
    {%- endif %}
    - require:
      - pkg: git
      - cmd: python-setuptools
