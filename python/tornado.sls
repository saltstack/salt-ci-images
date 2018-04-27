{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

{% set on_py26 = True if grains.get('pythonexecutable', '').endswith('2.6') else False %}
{% set debian8 = grains.os == 'Debian' and grains.osmajorrelease|int == 8 %} 

install-tornado:
  module.run:
    - name: pip.install
    - pkgs:
  {%- if on_py26 or debian8 %}
      - tornado==4.4.3
  {%- else %}
      - tornado{{ salt.pillar.get('tornado:version', '<5.0.0') }}"
  {%- endif %}
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
