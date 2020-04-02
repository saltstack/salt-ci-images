{%- if grains['os_family'] == 'RedHat' %}
  {%- if grains['os'] in ('Fedora', 'Amazon') %}
    {%- if grains['osrelease'].startswith('2018') %}
      {%- set python3_dev = 'python36-devel' %}
    {%- else %}
      {%- set python3_dev = 'python3-devel' %}
    {%- endif %}
    {%- if grains['osrelease'].startswith('2018') %}
      {#- Amazon Linux 1 #}
      {%- set python2_dev = 'python27-devel' %}
    {%- elif salt.grains.get('osmajorrelease')|int >= 26 %}
      {%- set python2_dev = 'python2-devel' %}
    {%- else %}
      {%- set python2_dev = 'python-devel' %}
    {%- endif %}
  {%- elif grains['os'] == 'CentOS' or grains['os'] == 'RedHat' %}
    {%- if grains['osrelease'].startswith('6') %}
      {%- set python2_dev = 'python27-devel' %}
      {%- set python3_dev = False %}
    {%- elif grains['osrelease'].startswith('8') %}
      {%- set python3_dev = 'python36-devel' %}
      {%- set python2_dev = False %}
    {%- else %}
      {%- set python3_dev = 'python3-devel' %}
      {%- set python2_dev = 'python-devel' %}
    {%- endif %}
  {%- else %}
    {%- set python3_dev = 'libpython36-devel' %}
    {%- set python2_dev = 'libpython-devel' %}
  {%- endif %}
{%- elif grains['os_family'] == 'Suse' %}
  {%- set python3_dev = 'python3-devel' %}
  {%- set python2_dev = 'python-devel' %}
{%- elif grains['os_family'] == 'Debian' %}
  {%- set python3_dev = 'python3-dev' %}
  {%- if salt.grains.get('osmajorrelease')|int < 10 %}
    {%- set python2_dev = 'python-dev' %}
  {%- else %}
    {%- set python2_dev = False %}
  {%- endif %}
{%- else %}
  {%- set python3_dev = 'python3-dev' %}
  {%- set python2_dev = 'python-dev' %}
{%- endif %}

{%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}

{%- if python2_dev %}
python2-dev:
  pkg.installed:
    - name: {{ python2_dev }}
    - aggregate: True
    {%- if grains['os'] == 'CentOS' and grains['osrelease'].startswith('6') %}
    - fromrepo: saltstack
    {%- endif %}
{%- endif %}

{%- if python3_dev %}
python3-dev:
  pkg.installed:
    - name: {{ python3_dev }}
    - aggregate: True
{%- endif %}

python-dev:
  test.succeed_without_changes:
    - require:
      {%- if python2_dev %}
      - python2-dev
      {%- endif %}
      {%- if python3_dev %}
      - python3-dev
      {%- endif %}
{%- endif %}
