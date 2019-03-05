{%- if grains['os_family'] == 'Debian' %}
  {%- set git = 'git-core' %}
{%- elif grains['os'] == 'Windows' %}
  {%- set PROGRAM_FILES = "%ProgramFiles%" %}
{%- elif grains['os'] == 'Gentoo' %}
  {%- set git = 'dev-vcs/git' %}
{%- else %}
  {%- set git = 'git' %}
{%- endif %}
{%- set git_binary = 'git' | which %}

force-sync-all:
  module.run:
    - name: saltutil.sync_all
    - order: 1
    - reload_modules: True

{%- if grains['os_family'] == 'Windows' %}
  {%- if not git_binary %}
include:
  - windows.repo

git-exists-in-path:
  win_path.exists:
    - name: 'C:\Program Files\Git\cmd'

git:
  pkg.installed:
    - name: git
    - refresh_modules: True
    - require:
      - git-exists-in-path
      - win-pkg-refresh
  {%- else %}
git:
  test.show_notification:
    - text: "Git is already installed"
  {%- endif %}
{%- endif %}

{%- if grains['os_family'] != 'Windows' %}
  {%- if grains['os_family'] == 'RedHat' %}
include:
   - python.ca-certificates
  {%- endif %}

git:
  pkg.installed:
    - name: {{ git }}
    - aggregate: True
    - refresh: True  # Ensure that pacman runs the first time with -Syu
    {%- if grains['os_family'] == 'RedHat' %}
    - require:
      - pkg: ca-certificates
    {%- endif %}
{%- endif %}
