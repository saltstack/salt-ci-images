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
{%- if grains['os_family'] == 'Debian' and grains['osmajorrelease'][0] == '7' %}
  - python.headers
{% endif %}

pip-install:
  cmd.run:
    {% if grains['os'] == 'Arch' %}
    - name: wget 'https://bootstrap.pypa.io/get-pip.py' && {{ python }} get-pip.py
    {% else %}
    - name: curl -L 'https://bootstrap.pypa.io/get-pip.py' | {{ python }}
    {% endif %}
    - cwd: /
    - reload_modules: True
    - require:
      - pkg: curl
      {% if grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == '5' %}
      - python26
      {% endif %}
      {% if grains['os_family'] == 'Debian' and grains['osmajorrelease'][0] == '7' %}
      - python-dev
      {% endif %}
