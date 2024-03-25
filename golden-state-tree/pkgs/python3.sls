{%- if grains['os_family'] in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
  {%- set python3_dev = False %}
{%- elif grains['os'] == 'Amazon' %}
  {%- set python3_dev = 'python3-devel' %}
{%- elif grains['os'] == 'Fedora' %}
  {%- set python3_dev = 'python3-devel' %}
{%- elif grains['os'] in ('AlmaLinux', 'Rocky', 'CentOS', 'CentOS Stream', 'RedHat') %}
  {%- if grains['osrelease'].startswith('8') %}
    {%- set python3_dev = 'python36-devel' %}
  {%- elif grains['osrelease'].startswith('9') %}
    {%- set python3_dev = 'python3-devel' %}
  {%- else %}
    {%- set python3_dev = 'python3-devel' %}
  {%- endif %}
{%- elif grains['os_family'] == 'Suse' %}
  {%- set python3_dev = 'python3-devel' %}
{%- elif grains['os_family'] == 'Debian' %}
  {%- set python3_dev = 'python3-dev' %}
{%- elif grains['os'] == 'VMware Photon OS' %}
  {%- set python3_dev = 'python3-devel' %}
{%- else %}
  {%- set python3_dev = 'python3-dev' %}
{%- endif %}

{%- if grains['os_family'] == 'Arch' %}
  {%- set python3 = 'python' %}
{%- elif grains["os_family"] == 'RedHat' and grains['osmajorrelease']|int == 8 %}
  {%- set python3 = 'python36' %}
{%- else %}
  {%- set python3 = 'python3' %}
{%- endif %}

python3:
  pkg.installed:
    - name: {{ python3 }}

{%- if python3_dev %}

python3-dev:
  pkg.installed:
    - name: {{ python3_dev }}
{%- endif %}
