{% if grains['os'] == 'Arch' %}
  {% set python = 'python2' %}
{% elif grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == '5' %}
  {% set python = 'python26' %}
{% else %}
  {% set python = 'python' %}
{% endif %}

{% set ez_setup_url = 'https://www.dropbox.com/s/r0ypau3mx4spspw/ez_setup.py' %}

include:
  - curl
  {%- if grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == '5' %}
  - python26
  {%- endif %}

python-setuptools:
  {#
    I'm installing setuptools this way since I want the most up to date version
    for all distributions. This avoids trying to handle different versions
    accepting different CLI options
  -#}
  cmd:
    - run
    - cwd: /
    - name: curl -L {{ ez_setup_url }} | {{ python }}{%
        if grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == '5' %} - --insecure{% endif %}
    - require:
      - pkg: curl
      {%- if grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == '5' %}
      - pkg: python26
      {%- endif %}
