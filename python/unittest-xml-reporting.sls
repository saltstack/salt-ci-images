include:
  - python.pip

unittest-xml-reporting:
  pip.installed:
    - name: https://github.com/s0undt3ch/unittest-xml-reporting/archive/features/test-class-based-capture.tar.gz#egg=unittest-xml-reporting
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require:
      - cmd: python-pip
