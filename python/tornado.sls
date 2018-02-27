{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

{% set on_py26 = True if grains.get('pythonexecutable', '').endswith('2.6') else False %}
{% set debian8 = grains.os == 'Debian' and grains.osmajorrelease|int == 8 %} 


tornado:
  pip.installed:
  {%- if on_py26 or debian8 %}
    - name: tornado==4.4.3
  {%- else %}
    - name: tornado
  {%- endif %}
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
