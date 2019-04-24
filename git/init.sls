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

{%- set patch_site = False %}
{%- if grains['os'].endswith('SUSE') and grains['osrelease'].startswith('15') %}
  {%- set patch_site = True %}
{%- endif %}

{# patch for https://bugs.python.org/issue30167 #}
{%- if patch_site %}
patch-site:
  file.patch:
    - name: /usr/lib64/python3.6/site.py
    - source: salt://36-site.patch
    - hash: b2f15653ae898c005e39c45581d942e95c07d39451b1ef5ed57556ff0a038f34
{%- endif %}

force-sync-all:
  module.run:
    - name: saltutil.sync_all
    - order: 1
    - reload_modules: True
{%- if patch_site %}
    - require:
      - file: patch-site
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
