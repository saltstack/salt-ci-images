include:
  - python.pip

SaltTesting:
  pip.installed:
    - name: git+{% if grains['osfinger'] == 'CentOS-5' %}git{% else %}https{% endif %}://github.com/saltstack/salt-testing.git@e5b1db1396a93150aefbf9c48f28cc50afa09836#egg=SaltTesting
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require:
      - cmd: python-pip

