include:
  - git
  - python.setuptools


supervisor:
  cmd:
    - run
    - cwd: /
    {% if grains['os'] == 'SmartOS' %}
    {#- Adapt to SmartOS's script directory #}
    - name: easy_install --script-dir=/opt/local/bin -U supervisor
    {%- else %}
    - name: easy_install --script-dir=/usr/bin -U supervisor
    {%- endif %}
    - require:
      - pkg: git
      - cmd: python-setuptools
