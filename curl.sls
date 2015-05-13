{%- if grains['os'] == 'Gentoo' %}
  {% set curl = 'net-misc/curl' %}
{% else %}
  {% set curl = 'curl' %}
{%- endif %}

{%- if grains['os'] == 'openSUSE' %}
include:
  - ca-certificates-mozilla
{%- endif %}

curl:
  pkg.installed:
    - name: {{ curl }}
    {%- if grains['os'] == 'openSUSE' %}
    - require:
      - pkg: ca-certificates-mozilla
    {%- endif %}


{% if grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == '5' %}
openssl:
  pkg.latest

update-openssl:
  cmd:
    - run
    - name: yum update -y --enablerepo=epel openssl
{% endif %}

{% if grains['os'] == 'Arch' %}
openssl:
  pkg.latest
{% endif %}
