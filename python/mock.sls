{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

{%- if grains['os'] == 'Ubuntu' and grains.get('osrelease', '').startswith('14') %}
  {%- set pinned_mock = 'mock' %}
{%- else %}
  {%- set pinned_mock = 'mock < 1.1.0' %}
{%- endif %}

mock:
  pip.installed:
    - name: {{ pinned_mock }}
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
