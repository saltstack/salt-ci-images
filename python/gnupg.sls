include:
  - python.pip

{%- if grains['os'] == 'Fedora' %}
python-gnupg:
  pkg.removed
{%- endif %}

gnupg:
  pip.installed:
    - name: python-gnupg
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require:
      {%- if grains['os'] == 'Fedora' %}
      - pkg: python-gnupg
      {%- endif %}
      - cmd: python-pip
