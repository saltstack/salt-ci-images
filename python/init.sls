{%- if grains['os_family'] != 'Windows' %}
include:
  {%- if pillar.get('py3', False) %}
  - python3
  - python.apt
  {%- else %}
  - python27
  {%- endif %}
  {%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
  {#- These distributions don't ship the develop headers separately #}
  - python.headers
  {%- endif %}
{%- endif %}
