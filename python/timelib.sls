include:
  - gcc
  - python.pip
{%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD') %}
{#- These distributions don't ship the develop headers separately #}
  - python.headers
{% endif %}

timelib:
  pip.installed:
    - require:
      {%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD') %}
      {#- These distributions don't ship the develop headers separately #}
      - pkg: python-dev
      {%- endif %}
      {%- if grains['os_family'] not in ('FreeBSD',) %}
        {#- FreeBSD always ships with gcc #}
      - pkg: gcc
      {%- endif %}
      - pkg: python-pip
    - mirrors:
      - http://g.pypi.python.org
      - http://c.pypi.python.org
      - http://pypi.crate.io
