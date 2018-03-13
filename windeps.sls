stop-minion:
  service.dead:
    - name: salt-minion
    - enable: False

include:
   - curl
   - python.setproctitle
   - python.pip
   - python.urllib3
   - python.dulwich
   - winrepo
   - python27

extend:
  curl:
    pip.installed:
      - bin_env: {{ salt['config.get']('salt_pip', 'c:\\salt\\bin\\Scripts\\pip.exe') }}
      - cwd: {{ salt['config.get']('salt_pip_cwd', 'c:\\salt\\bin\\Scripts') }}
  upgrade-installed-pip:
    pip.installed:
      - bin_env: {{ salt['config.get']('salt_pip', 'c:\\salt\\bin\\Scripts\\pip.exe') }}
      - cwd: {{ salt['config.get']('salt_pip_cwd', 'c:\\salt\\bin\\Scripts') }}
  urllib3:
    pip.installed:
      - use_wheel: true
      - bin_env: {{ salt['config.get']('salt_pip', 'c:\\salt\\bin\\Scripts\\pip.exe') }}
      - cwd: {{ salt['config.get']('salt_pip_cwd', 'c:\\salt\\bin\\Scripts') }}
  dulwich:
    pip.installed:
      - bin_env: {{ salt['config.get']('salt_pip', 'c:\\salt\\bin\\Scripts\\pip.exe') }}
      - cwd: {{ salt['config.get']('salt_pip_cwd', 'c:\\salt\\bin\\Scripts') }}
      - global_options: '--pure'
vcc:
  pkg.installed:
    - name: vcforpython27
    - require:
      - stop-minion
      - win-pkg-refresh
      - force-sync-all
      - python2
