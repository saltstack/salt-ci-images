{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

{#- boto is sometimes installed on amazon images, we want to make sure we install the latest version so remove the installed ones here if they are already installed #}
uninstall boto modules:
  pip.removed:
    - names:
      - boto
      - botocore
      - boto3
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}

boto:
  pip.installed:
    - name: boto >= 2.46.0
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    {%- if salt['config.get']('pip_target', None)  %}
    - target: {{ salt['config.get']('pip_target') }}
    {%- endif %}
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}

boto3:
  pip.installed:
    - name: boto3
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    {%- if salt['config.get']('pip_target', None)  %}
    - target: {{ salt['config.get']('pip_target') }}
    {%- endif %}
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}

