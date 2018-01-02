{% set include_paramiko = False %}
{% if grains['os'] in ['Debian', 'Ubuntu'] %}
  {% set include_paramiko = True %}
{% endif %}

include:
  - python.pip
  {%- if include_paramiko %}
  - python.paramiko
  {%- endif %}

{% if grains['os'] in ['Ubuntu', 'Debian'] %}
pyez dependencies:
  pkg.installed:
    - pkgs:
      - libxslt1-dev
      - libssl-dev
      - libffi-dev
{% elif grains['os'] in ['Fedora', 'CentOS'] %}
pyez dependencies:
  pkg.installed:
    - pkgs:
      - libxml2-devel
      - libxslt-devel
      - gcc
      - openssl-devel
      - libffi-devel
      - redhat-rpm-config
{% elif grains['os'] == 'FreeBSD' %}
pyez dependencies:
  pkg.installed:
    - pkgs:
      - libxml2
      - libxslt
{% endif %}

junos-eznc:
  pip.installed:
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://nexus.c7.saltstack.net/repository/salt-proxy/simple
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: pip-install
      {%- if include_paramiko %}
      - pip: paramiko
      {%- endif %}
