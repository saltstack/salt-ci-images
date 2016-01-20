{% set distro = salt['grains.get']('oscodename', '')  %}
{% set os_family = salt['grains.get']('os_family', '') %}
{% set os_major_release = salt['grains.get']('osmajorrelease', '') %}

{% if os_family == 'RedHat' and os_major_release[0] == '5' %}
  {% set on_redhat_5 = True %}
{% else %}
  {% set on_redhat_5 = False %}
{% endif %}

{% if os_family == 'Debian' and distro == 'wheezy' %}
  {% set on_debian_7 = True %}
{% else %}
  {% set on_debian_7 = False %}
{% endif %}

{% if os_family == 'Arch' %}
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

{% set get_pip = '{0} get-pip.py pip==7.1.2'.format(python) %}

pip-install:
  cmd.run:
    {% if on_arch %}
    - name: wget 'https://bootstrap.pypa.io/get-pip.py' && {{ get_pip }}
    {% else %}
    - name: curl -L 'https://bootstrap.pypa.io/get-pip.py' -o get-pip.py && {{ get_pip }}
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
