{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}

{%- if os_family == 'RedHat' and os_major_release == 6 %}
  {%- set on_redhat_6 = True %}
{%- else %}
  {%- set on_redhat_6 = False %}
{%- endif %}

{%- if os_family == 'Ubuntu' and os_major_release == 14 %}
  {%- set on_ubuntu_14 = True %}
{%- else %}
  {%- set on_ubuntu_14 = False %}
{%- endif %}

{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
  {%- if on_redhat_6 or on_ubuntu_14 %}
  - curl
  {%- endif %}
{%- endif %}

{%- set nox_version = '2018.10.17' %}

{#- %- if not on_redhat_6 and not on_ubuntu_14 %} #}
{%- if False %}
{#- For now, always download the single binary #}
nox:
  pip3.installed:
    - name: 'nox == {{ nox_version }}'
    {%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
    {%- endif %}
{%- else %}
download-nox:
  cmd.run:
    - name: curl -L https://oss-nexus.aws.saltstack.net/repository/salt-dev-raw/nox/{{ nox_version }}/nox -o /usr/bin/nox
    - require:
      - pkg: curl

fix-nox-perms:
  file.managed:
    - name: /usr/bin/nox
    - create: false
    - replace: false
    - mode: '0755'
{%- endif %}
