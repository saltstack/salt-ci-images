{% from '_python.sls' import python with context %}

{% set ez_setup_url = 'https://www.dropbox.com/s/r0ypau3mx4spspw/ez_setup.py' %}

{% if grains['osfinger'] == 'CentOS-5' %}
  {% set easy_install = 'easy_install-2.6' %}
{% else %}
  {% set easy_install = 'easy_install' %}
{% endif %}

include:
  - curl
  {%- if grains['osfinger'] == 'CentOS-5' %}
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
    - name: curl -L {{ ez_setup_url }} {% if grains['osfinger'] == 'CentOS-5' %}--insecure{% endif %} | {{ python }}{% if grains['osfinger'] == 'CentOS-5' %} - --insecure{% endif %}
    - require:
      - pkg: curl
      {%- if grains['osfinger'] == 'CentOS-5' %}
      - pkg: python26
      {%- endif %}
