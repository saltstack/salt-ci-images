{% if not ( pillar.get('py3', False) and grains['os'] == 'Windows' ) %}

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

{% endif %}
