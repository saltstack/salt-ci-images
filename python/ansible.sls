{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

install_ansible:
  pip2.installed:
    - name: ansible
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
