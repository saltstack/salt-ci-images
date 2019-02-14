{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

{%- if grains['os'] == 'Fedora' %}
python-gnupg:
  pkg.removed
{%- endif %}

gnupg:
  pip.installed:
    - name: python-gnupg
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
{% if grains['os'] not in ('Windows',) %}
    - require:
      {%- if grains['os'] == 'Fedora' %}
      - pkg: python-gnupg
      {%- endif %}
      - cmd: pip-install
{% endif %}
