{%- set salt_dir = salt['config.get']('python_install_dir', 'c:\\salt').rstrip('\\') %}
{%- set scripts_dir = salt_dir | path_join('bin', 'Scripts') %}

include:
  {%- if salt['config.get']('py3', False) %}
    - python3
  {%- else %}
    - python27
  {%- endif %}

update-env-vars:
  environ.setenv:
    - name: PATH
    - value: '{{ scripts_dir }};$Path'
    - permanent: true
    - order: 2
    - require:
    {%- if salt['config.get']('py3', False) %}
      - python3
    {%- else %}
      - python2
    {%- endif %}
