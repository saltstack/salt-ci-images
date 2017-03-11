{%- set fedora = True if grains['os'] == 'Fedora' else False %}
{%- set fedora23 = True if fedora and grains['osrelease'] == '23' else False %}
{%- set fedora24 = True if fedora and grains['osrelease'] == '24' else False %}

{%- if fedora23 %}
  {%- set python_dev = 'python-devel' %}
{%- else %}
  {%- set python_dev = 'python-dev' %}
{%- endif %}

{%- if grains['os'] not in ('Windows') %}
include:
  {%- if grains['os_family'] not in ('FreeBSD', 'Gentoo') %}
  - gcc
  {%- endif %}
  {%- if fedora23 or fedora24 %}
  - redhat-rpm-config
  {% endif %}
  - python.pip
{%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
{#- These distributions don't ship the develop headers separately #}
  - python.headers
{%- endif %}
{%- endif %}

psutil:
  pip.installed:
    - upgrade: True
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
{% if grains['os'] not in ('Windows') %}
    - require:
      {%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
      {#- These distributions don't ship the develop headers separately #}
      - pkg: {{ python_dev }}
      {%- endif %}
      {%- if fedora23 or fedora24 %}
      - pkg: redhat-rpm-config
      {% endif %}
      {%- if grains['os_family'] not in ('FreeBSD', 'Gentoo') %}
        {#- FreeBSD always ships with gcc #}
      - pkg: gcc
      {%- endif %}
      - cmd: pip-install
{% endif %}
