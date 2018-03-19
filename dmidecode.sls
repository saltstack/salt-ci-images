{% if grains['os'] == 'Windows' %}
  {% set install_method = 'pip.installed' %}
{% else %}
  {% set install_method = 'pkg.installed' %}
{% endif %}

install-dmidecode:
  {{ install_method }}:
    - name: dmidecode
    {% if install_method == 'pkg.installed' %}
    - aggregate: True
    {%- endif %}
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
