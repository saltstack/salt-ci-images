{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

six:
  pip.installed:
    - upgrade: true
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}

{#- Upgrading six on Fedora breaks urllib3 because of a symlink to six #}
{#- recreate the symlink under to point to new location #}
{%- if grains['os'] in ('Fedora',) %}
{%- set python_version = grains.get('pythonversion')[:2] %}
{%- set urllib_six = "/usr/lib/python" + python_version[0]|string + "." + python_version[1]|string + "/site-packages/urllib3/packages/six.py" %}
{%- if salt['file.is_link'](urllib_six) %}
{{ urllib_six }}:
  file.symlink:
    - target: {{ "/usr/local/lib/python" + python_version[0]|string + "." + python_version[1]|string + "/site-packages/urllib3/packages/six.py" }}
{%- endif %}
{%- endif %}
