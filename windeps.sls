{% set salt_dir = salt['config.get']('salt_dir', 'c:\\salt').rstrip('\\') %}
{% set bin_env = salt_dir + '\\bin\\Scripts\\pip.exe' %}
{% set cwd_dir = salt_dir + '\\bin\\Scripts' %}

stop-minion:
  service.dead:
    - name: salt-minion
    - enable: False

include:
    - python.urllib3
    - python.dulwich
  {% if salt['config.get']('py3', False) %}
    - python3
  {% else %}
    - python27
  {% endif %}

extend:
  urllib3:
    pip.installed:
      - use_wheel: true
      - bin_env: {{ bin_env }}
      - cwd: {{ cwd_dir }}
  dulwich:
    pip.installed:
      - bin_env: {{ bin_env }}
      - cwd: {{ cwd_dir }}
      - global_options: '--pure'
      - require:
        - urllib3
{% if salt['config.get']('py3', False) %}
  python3:
    pkg.installed:
      - aggregate: False
      - require:
        - win-pkg-refresh
{% else %}
  python2:
    pkg.latest:
      - require:
        - win-pkg-refresh
{% endif %}

download-git-repos:
   module.run:
     - name: winrepo_bootstrap.download_git_repos
     - require:
       - dulwich

win-pkg-refresh:
  module.run:
    - name: pkg.refresh_db
    - require:
      - download-git-repos

vcpp-compiler:
  pkg.installed:
  {% if salt['config.get']('py3', False) %}
    - name: ms-vcpp-2015-build-tools
  {% else %}
    - name: vcforpython27
  {% endif %}
    - require:
      - win-pkg-refresh

git-exists-in-path:
  win_path.exists:
    - name: 'C:\Program Files\Git\cmd'

git:
  pkg.installed:
    - refresh_modules: True
    - require:
      - win-pkg-refresh
      - git-exists-in-path

windeps-sync-all:
  module.run:
    - name: saltutil.sync_all
    - require:
      - win-pkg-refresh
      - git
      - vcpp-compiler
    {% if salt['config.get']('py3', False) %}
      - python3
    {% else %}
      - python2
    {% endif %}
