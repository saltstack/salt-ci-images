{%- if grains['os_family'] == 'RedHat' %}
  {%- if grains['os'] in ('Fedora', 'Amazon') %}
    {%- if pillar.get('py3', False) %}
      {%- if grains['osrelease'].startswith('2018') %}
        {%- set python_dev = 'python36-devel' %}
      {%- else %}
        {%- set python_dev = 'python3-devel' %}
      {%- endif %}
    {%- else %}
      {%- if grains['osrelease'].startswith('2018') %}
        {#- Amazon Linux 1 #}
        {%- set python_dev = 'python27-devel' %}
      {%- elif salt.grains.get('osmajorrelease')|int >= 26 %}
        {%- set python_dev = 'python2-devel' %}
      {%- else %}
        {%- set python_dev = 'python-devel' %}
      {%- endif %}
    {%- endif %}
  {%- elif grains['os'] == 'CentOS' or grains['os'] == 'RedHat' %}
    {%- if grains['osrelease'].startswith('6') %}
      {%- set python_dev = 'python27-devel' %}
    {%- else %}
      {%- if pillar.get('py3', False) %}
        {%- set python_dev = 'python3-devel' %}
      {%- else %}
        {%- set python_dev = 'python-devel' %}
      {%- endif %}
    {%- endif %}
  {%- else %}
    {%- if pillar.get('py3', False) %}
      {%- set python_dev = 'libpython36-devel' %}
    {%- else %}
      {%- set python_dev = 'libpython-devel' %}
    {%- endif %}
  {%- endif %}
{%- elif grains['os_family'] == 'Suse' %}
  {%- if pillar.get('py3', False) %}
    {%- set python_dev = 'python3-devel' %}
  {%- else %}
    {%- set python_dev = 'python-devel' %}
  {%- endif %}
{%- elif grains['os_family'] == 'Debian' %}
  {%- if pillar.get('py3', False) %}
    {%- set python_dev = 'python3-dev' %}
  {%- else %}
    {%- set python_dev = 'python-dev' %}
  {%- endif %}
{%- else %}
  {%- if pillar.get('py3', False) %}
    {%- set python_dev = 'python3-dev' %}
  {%- else %}
    {%- set python_dev = 'python-dev' %}
  {%- endif %}
{%- endif %}

{%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
python-dev:
  pkg.installed:
    - name: {{ python_dev }}
    - aggregate: True
    {%- if grains['os'] == 'CentOS' and grains['osrelease'].startswith('6') %}
    - fromrepo: saltstack
    {%- endif %}
{%- endif %}
