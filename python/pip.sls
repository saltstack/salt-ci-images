{% if grains['os'] == 'Arch' %}
  {% set python = 'python2' %}
{% elif grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == '5' %}
  {% set python = 'python26' %}
{% else %}
  {% set python = 'python' %}
{% endif %}


include:
  - curl
  {% if grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == '5' %}
  - python26
  {% endif %}

pip-install:
  cmd.run:
    - name: curl -L 'https://bootstrap.pypa.io/get-pip.py' | {{ python }}
    - cwd: /
    - reload_modules: True
    - require:
      - pkg: curl
      {% if grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == '5' %}
      - python26
      {% endif %}
