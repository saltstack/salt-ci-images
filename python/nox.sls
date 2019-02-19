{%- if grains['os'] == 'Windows' %}
  {%- set binary_name = 'nox.exe' %}
  {%- set binary_path = 'C:\\Program Files\\nox.exe' %}
  {%- set source_hash = 'f594344d4d06ad0477d43b87a490976b1d26f537' %}
{%- else %}
  {%- set binary_name = 'nox' %}
  {%- set binary_path = '/usr/bin/nox' %}
  {%- set source_hash = '20ee58197b8cbfed151570b8d0aaea7555e2e540' %}
{%- endif %}
{%- set nox_version = '2018.10.17' %}

download-nox:
  file.managed:
    - name: '{{ binary_path }}'
    - source: https://oss-nexus.aws.saltstack.net/repository/salt-dev-raw/nox/{{ nox_version }}/{{ binary_name }}
    {#- Don't check against source hash since the binaries aren't yet stable
    - source_hash: '{{ source_hash }}'
    #}
    - skip_verify: true
    {%- if grains['os'] != 'Windows' %}
    - mode: '0755'
    {%- endif %}
    - create: true
    - replace: false
