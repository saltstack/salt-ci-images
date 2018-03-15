{% if grains['os_family'] == 'Debian' %}
  {% set git = 'git-core' %}
{%- elif grains['os'] == 'Gentoo' %}
  {% set git = 'dev-vcs/git' %}
{% else %}
  {% set git = 'git' %}
{% endif %}

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
