{%- set os = grains['os'] %}
{%- set os_family = grains['os_family'] %}
{%- set osrelease = grains['osrelease'] %}
{%- set osmajorrelease = grains.get('osmajorrelease', '')|int %}

{%- if os_family in ('Arch', 'RedHat') or os == 'Ubuntu' and osmajorrelease >= 16 %}
install_pygit2:
  pkg.installed:
    {%- if os_family == 'Arch' %}
    - name: python2-pygit2
    {%- else %}
    - name: python-pygit2
    {%- endif %}
{% endif %}
