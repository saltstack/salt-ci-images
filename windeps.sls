{% set salt_dir = salt['config.get']('salt_dir', 'c:\\salt').rstrip('\\') %}
{% set bin_env = salt_dir + '\\bin\\Scripts\\pip.exe' %}
{% set cwd_dir = salt_dir + '\\bin\\Scripts' %}

stop-minion:
  service.dead:
    - name: salt-minion
    - enable: False

include:
   - python.pip
   - python.urllib3
   - python.dulwich
   - curl
   - winrepo
{% if salt['config.get']('py3', False) %}
   - python3
{% else %}
   - python27
{% endif %}

extend:
  curl:
    pip.installed:
      - bin_env: {{ bin_env }}
      - cwd: {{ cwd_dir }}
  upgrade-installed-pip:
    pip.installed:
      - bin_env: {{ bin_env }}
      - cwd: {{ cwd_dir }}
  urllib3:
    pip.installed:
      - use_wheel: true
      - bin_env: {{ bin_env }}
      - cwd: {{ cwd_dir }}
      - require:
        - upgrade-installed-pip
  dulwich:
    pip.installed:
      - bin_env: {{ bin_env }}
      - cwd: {{ cwd_dir }}
      - global_options: '--pure'
      - require:
        - upgrade-installed-pip
        - urllib3
{% if salt['config.get']('py3', False) %}
  install_python3:
    pkg.installed:
      - require:
        - win-pkg-refresh
{% else %}
  python2:
    pkg.latest:
      - require:
        - win-pkg-refresh
{% endif %}

{% if salt['config.get']('py3', False) %}
ms-vcpp-2015-build-tools:
  pkg.installed:
    - require:
      - win-pkg-refresh
      - install_python3
{% else %}
vcc:
  pkg.installed:
    - name: vcforpython27
    - require:
      - win-pkg-refresh
      - python2
{% endif %}

git:
  pkg.installed:
    - require:
      - win-pkg-refresh
