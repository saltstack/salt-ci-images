{% if grains['os'] == 'Windows' %}
  {% set install_method = 'pip.installed' %}
{% else %}
  {% set install_method = 'pkg.installed' %}
{% endif %}

install-dmidecode:
  {{ install_method }}:
    - name: dmidecode
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    {% if install_method == 'pkg.installed' %}
    - aggregate: True
    {%- endif %}
