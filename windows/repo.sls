{%- set salt_dir = salt['config.get']('salt_dir', 'c:\\salt').rstrip('\\') %}
{%- set bin_env = salt_dir + '\\bin' %}
{%- set pip_bin = bin_env + '\\Scripts\\pip.exe' %}
{%- set cwd_dir = bin_env + '\\Scripts' %}
{%- set git_binary = 'git' | which %}
{%- if not git_binary  %}
include:
  - python.urllib3
  - python.dulwich

extend:
  urllib3:
    pip.installed:
      - use_wheel: true
      {#- We explicitly pass bin_env because we want these requirements install for salt itself to work #}
      - bin_env: {{ bin_env }}
      - cwd: {{ cwd_dir }}
  dulwich:
    pip.installed:
      {#- We explicitly pass bin_env because we want these requirements install for salt itself to work #}
      - bin_env: {{ bin_env }}
      - cwd: {{ cwd_dir }}
      - global_options: '--pure'
      - require:
        - urllib3
      - reload_modules: True
{%- endif %}

download-git-repos:
  module.run:
    {%- if git_binary %}
    - name: winrepo.update_git_repos
    {%- else %}
    - name: winrepo_bootstrap.download_git_repos
    - require:
      - dulwich
    {%- endif %}
    - order: 2

win-pkg-refresh:
  module.run:
    - name: pkg.refresh_db
    - verbose: true
    - failhard: true
    - require:
      - download-git-repos
    - order: 2
