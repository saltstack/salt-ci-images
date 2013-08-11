{% if grains['os'] == 'FreeBSD' %}
  {% set pip = 'py27-pip' %}
{% elif grains['os'] == 'Arch' %}
  {% set pip = 'python2-pip'%}
{% else %}
  {% set pip = 'python-pip'%}
{% endif %}

python-pip:
  pkg.installed:
    - name: {{ pip }}
