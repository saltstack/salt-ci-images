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
    {%- if [int(i) for i in grains.get('saltversion').split('.') if i.isdigit()][:2] >= [0, 17] %}
    - mirrors:
      - http://g.pypi.python.org
      - http://c.pypi.python.org
      - http://pypi.crate.io
    {% endif %}
