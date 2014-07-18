{% if grains['os'] == 'Ubuntu' %}
{% set cgmanager = 'libcgmanager0' %}
{% elif grains['os'] == 'Arch' %}
{% set cgmanager = 'cgmanager' %}
{% else %}
{% set cgmanager = 'libcgmanager' %}
{% endif %}
lxc:
  pkg.latest:
    - pkgs:
      - lxc
      - {{ cgmanager }}
