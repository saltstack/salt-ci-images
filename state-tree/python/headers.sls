{%- if grains['os_family'] in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
  {%- set python3_dev = False %}
{%- elif grains['os'] == 'Amazon' %}
  {%- set python3_dev = 'python3-devel' %}
{%- elif grains['os'] == 'Fedora' %}
  {%- set python3_dev = 'python3-devel' %}
{%- elif grains['os'] in ('AlmaLinux', 'CentOS', 'CentOS Stream', 'RedHat') %}
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

{%- if python3_dev %}
python3-dev:
  pkg.installed:
    - name: {{ python3_dev }}
    - aggregate: False
{%- endif %}

python-dev:
  {%- if not python3_dev %}
  test.succeed_without_changes
  {%- else %}
  test.succeed_without_changes:
    - require:
      {%- if python3_dev %}
      - python3-dev
      {%- endif %}
  {%- endif %}
