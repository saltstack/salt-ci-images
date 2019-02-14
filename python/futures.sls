{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

futures:
  pip.installed:
    - name: futures
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
