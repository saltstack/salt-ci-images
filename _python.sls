{% if grains['os'] == 'Arch' %}
  {% set python = 'python2' %}
{% elif grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == 5 %}
  {% set python = 'python26' %}
{% else %}
  {% set python = 'python' %}
{% endif %}
