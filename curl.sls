{%- if grains['os'] == 'Gentoo' %}
  {% set curl = 'net-misc/curl' %}
{% else %}
  {% set curl = 'curl' %}
{%- endif %}

{% if grains['os'] in ('Windows') %}
  {% set install_method = 'pip.installed' %}
  {% set curl = 'pycurl' %}
{% else %}
  {% set install_method = 'pkg.installed' %}
{% endif %}

{%- if grains['os_family'] == 'RedHat' or grains['os'] == 'openSUSE' %}
include:
  {%- if grains['os'] == 'openSUSE' %}
   - ca-certificates-mozilla
  {%- elif grains['os_family'] == 'RedHat' %}
   - python.ca-certificates
  {%- endif %}
{%- endif %}

{%- if grains['os_family'] == 'Darwin' %}
mac-ruby-upgrade:
  rvm.installed:
    - name: ruby-2.4.4
    - default: true
    - require_in:
      - pkg: curl
{%- endif %}

curl:
  {{ install_method }}:
    - name: {{ curl }}
    {%- if install_method == 'pkg.installed' %}
    - aggregate: True
    {%- endif %}
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    {%- if grains['os_family'] == 'RedHat' or grains['os'] == 'openSUSE' %}
    - require:
      {%- if grains['os'] == 'openSUSE' %}
      - pkg: ca-certificates-mozilla
      {%- elif grains['os_family'] == 'RedHat' %}
      - pkg: ca-certificates
      {%- endif %}
    {%- endif %}


{% if grains['os_family'] == 'RedHat' and grains['osmajorrelease']|int == 5 %}
openssl:
  pkg.latest:
    - aggregate: True

update-openssl:
  cmd:
    - run
    - name: yum update -y --enablerepo=epel openssl
{% endif %}

{% if grains['os'] == 'Arch' %}
openssl:
  pkg.latest:
    - aggregate: True
{% endif %}
