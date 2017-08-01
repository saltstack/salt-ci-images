{% if grains['os'] not in ('Windows') %}
include:
  - python.pip
{% endif %}

boto:
  pip.installed:
    - name: boto >= 2.33.0
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    {%- if salt['config.get']('pip_target', None)  %}
    - target: {{ salt['config.get']('pip_target') }}
    {%- endif %}
{% if grains['os'] not in ('Windows') %}
    - require:
      - cmd: pip-install
{% endif %}

boto3:
  pip.installed:
    - name: boto3
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    {%- if salt['config.get']('pip_target', None)  %}
    - target: {{ salt['config.get']('pip_target') }}
    {%- endif %}
{% if grains['os'] not in ('Windows') %}
    - require:
      - cmd: pip-install
{% endif %}

