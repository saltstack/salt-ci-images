# Various bind packages are needed to run dig tests
{%- if grains['os_family'] in ('RedHat', 'Suse') and grains['os'] != 'VMware Photon OS' %}
  {%- set dnsutils = 'bind-utils' %}
{%- elif grains['os'] == 'Gentoo' %}
  {%- set dnsutils = 'bind-tools' %}
{%- elif grains['os'] == 'Arch' %}
  {%- set dnsutils = 'bind' %}
{%- elif grains['os_family'] == 'FreeBSD' %}
  {%- set dnsutils = 'bind-tools' %}
{%- elif grains['os'] == 'VMware Photon OS' %}
  {%- set dnsutils = 'bindutils' %}
{%- else %}
  {%- set dnsutils = 'dnsutils' %}
{%- endif %}

dnsutils:
  pkg.installed:
    - name: {{ dnsutils }}
