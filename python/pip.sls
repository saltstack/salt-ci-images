{% if grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == '5' %}
  {% set on_redhat_5 = True %}
{% else %}
  {% set on_redhat_5 = False %}
{% endif %}

{% if grains['os'] == 'Debian' and grains['osmajorrelease'][0] == '7' %}
  {% set on_debian_7 = True %}
{% else %}
  {% set on_debian_7 = False %}
{% endif %}

{% if grains['os'] == 'Arch' %}
  {% set on_arch = True %}
{% else %}
  {% set on_arch = False %}
{% endif %}

{% if on_arch %}
  {% set python = 'python2' %}
{% elif on_redhat_5 %}
  {% set python = 'python26' %}
{% else %}
  {% set python = 'python' %}
{% endif %}


include:
  - curl
  {% if on_redhat_5 %}
  - python26
  {% endif %}
  {%- if on_debian_7 %}
  - python.headers
  {% endif %}

pip-install:
  cmd.run:
    {% if on_arch %}
    - name: wget 'https://bootstrap.pypa.io/get-pip.py' && {{ python }} get-pip.py
    {% else %}
    - name: curl -L 'https://bootstrap.pypa.io/get-pip.py' | {{ python }}
    {% endif %}
    - cwd: /
    - reload_modules: True
    - require:
      - pkg: curl
      {% if on_redhat_5 %}
      - pkg: python26
      {% endif %}
      {% if on_debian_7 %}
      - pkg: python-dev
      {% endif %}
