{% if grains['os_family'] == 'Debian' %}
  {% set git = 'git-core' %}
{% else %}
  {% set git = 'git' %}
{% endif %}

git:
  pkg.installed:
    - name: {{ git }}
