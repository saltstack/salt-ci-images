{%- set os = grains['os'] %}
{%- set os_family = grains['os_family'] %}
{%- set osrelease = grains['osrelease'] %}
{%- set osmajorrelease = grains.get('osmajorrelease', '')|int %}

{%- if os_family == 'Arch' %}
    {%- set pygit2_pkg = 'python2-pygit2' %}
{%- elif os == 'Fedora' %}
    {%- if pillar.get('py3', False) %}
        {%- set pygit2_pkg = 'python3-pygit2' %}
    {%- else %}
        {%- set pygit2_pkg = 'python2-pygit2' %}
    {%- endif %}
{%- else %}
    {%- set pygit2_pkg = 'python-pygit2' %}
{%- endif %}

{%- if os != 'Amazon' and (os_family in ('Arch', 'RedHat') or os == 'Ubuntu' and osmajorrelease >= 16) %}
install_pygit2:
  pkg.installed:
    - name: {{ pygit2_pkg  }}
    - aggregate: True
{%- endif %}
