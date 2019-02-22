{%- if grains['os'] == 'Windows' %}
  {%- set python2 = 'python2_x86' %}
{%- elif grains['os'] == 'openSUSE' %}
  {%- set python2 = 'python' %}
{%- elif grains['os'] == 'CentOS' or grains['os'] == 'RedHat' %}
  {%- if grains['osrelease'].startswith('6') %}
    {%- set python2 = 'python27' %}
  {%- else %}
    {%- set python2 = 'python' %}
  {%- endif %}
{%- elif grains['os'] in ('Ubuntu', 'Debian') %}
  {%- set python2 = 'python2.7' %}
{%- elif grains['os'] == 'Fedora' %}
  {%- set python2 = 'python2' %}
{%- elif grains['os_family'] == 'Arch' %}
  {%- set python2 = 'python2' %}
{%- else %}
  {%- set python2 = 'python' %}
{%- endif %}

python2:
  pkg.latest:
    - name: {{ python2 }}
    - aggregate: True
