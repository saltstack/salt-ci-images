include:
  - python.pip

# Newer versions of paramiko (2.2.0) require a minimum version of the
# PyNaCl lib of 1.0.1, which doesn't install correctly on some distros.
# This is pinned at 2.1.2 until the installation issues are resolved.
paramiko:
  pip.installed:
    - name: paramiko == 2.1.2
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://nexus.c7.saltstack.net/repository/salt-proxy/simple
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: pip-install