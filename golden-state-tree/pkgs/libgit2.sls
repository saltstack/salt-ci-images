{%- if grains['os'] in ['Ubuntu', 'Debian'] %}
  {%- set libgit2 = "libgit2-dev" %}
{%- elif grains['os'] in ['Fedora'] or grains.os_family == 'Suse' %}
  {%- set libgit2 = "libgit2-devel" %}
{%- else %}
  {%- set libgit2 = "libgit2" %}
{%- endif %}

{%- if grains['os'] in ('AlmaLinux', 'Rocky', 'CentOS', 'CentOS Stream') %}
include:
  - os.rocky.pkgs.epel-release
{%- elif grains['oscodename'] == 'Amazon Linux 2' %}
include:
  - os.amazon.pkgs.epel-release
{%- elif grains['os_family'] == 'Suse' %}
include:
  - pkgs.openssl-dev
{%- endif %}

libgit2-dev:
  pkg.installed:
    - name: {{ libgit2 }}
{%- if grains['os_family'] == 'Suse' %}
    - require:
      - openssl-dev
{%- endif %}
