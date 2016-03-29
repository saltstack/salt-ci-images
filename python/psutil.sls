{% set fedora23 = True if grains['osfinger'] == 'Fedora-23' else False %}

{% if fedora23 %}
  {%- set python_dev = 'python-devel' %}
{% else %}
  {%- set python_dev = 'python-dev' %}
{% endif %}

include:
  {%- if grains['os_family'] not in ('FreeBSD', 'Gentoo') %}
  - gcc
  {%- endif %}
  {% if fedora23 %}
  - redhat-rpm-config
  {% endif %}
  - python.pip
{%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
{#- These distributions don't ship the develop headers separately #}
  - python.headers
{% endif %}

psutil:
  pip.installed:
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - require:
      {%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
      {#- These distributions don't ship the develop headers separately #}
      - pkg: {{ python_dev }}
      {%- endif %}
      {% if fedora23 %}
      - pkg: redhat-rpm-config
      {% endif %}
      {%- if grains['os_family'] not in ('FreeBSD', 'Gentoo') %}
        {#- FreeBSD always ships with gcc #}
      - pkg: gcc
      {%- endif %}
      - cmd: pip-install
