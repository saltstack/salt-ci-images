{% if grains['os_family'] == 'Debian' %}
  {% set git = 'git-core' %}
{%- elif grains['os'] == 'Gentoo' %}
  {% set git = 'dev-vcs/git' %}
{% else %}
  {% set git = 'git' %}
{% endif %}

git:
  pkg.installed:
    - name: {{ git }}
    - refresh: True  # Ensure that pacman runs the first time with -Syu
