include:
  - gcc
  - python.pip
  - python.headers

pyzmq:
  pkg.installed:
    - name: {{ 'g++' if grains.os_family == 'Debian' else 'gcc-c++' }}

  pip.installed:
    - name: pyzmq{{salt.pillar.get('pyzmq:version', '')}}
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    - global_options:
      - fetch_libzmq
    - install_options:
      - --zmq=bundled
    - require:
      - cmd: pip-install
      - pkg: gcc
