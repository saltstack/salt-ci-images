include:
  - python.setuptools
  {%- if grains['os'] == 'openSUSE' %}
  {#- Yes! openSuse ships xml as separate package #}
  - python.xml
  {%- endif %}

python-pip:
  {#
    I'm installing pip this way since I want the most up to date version
    for all distributions. This avoids trying to handle different versions
    accepting different CLI options.

    This was originally needed because the pip package installed in RHEL/CentOS 5
    was for python 2.4 and I could not find a python 2.6 pacakge of it.
  -#}
  cmd:
    - run
    - cwd: /
    {% if grains['os'] == 'SmartOS' %}
    {#- Adapt to SmartOS's script directory #}
    - name: easy_install --script-dir=/opt/local/bin -U pip virtualenv
    {%- else %}
    - name: easy_install --script-dir=/usr/bin -U pip virtualenv
    {%- endif %}
    - require:
      {%- if grains['os'] == 'openSUSE' %}
      {#- Yes! openSuse ships xml as separate package #}
      - pkg: python-xml
      {%- endif %}
      - cmd: python-setuptools
