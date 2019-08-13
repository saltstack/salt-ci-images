{%- if grains['os'] == 'Windows' %}

{%- set install_heartbeat = true %}
{%- set heartbeat_url = 'https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-7.3.0-windows-x86_64.zip' %}
{%- set heartbeat_hash = 'bcb5412d9c9c18ff87abca3e0de4b51321479e6dfa964a4efd41287b578a645bbc957fb35a94e0d2e5a3a7f269d10865bc9dcf42c70eb0c3844b24cbb68db31b' %}
{%- set heartbeat_path = 'c:\\heartbeat-7.3.0-windows-x86_64.zip'  %}
# Unused on windows
{%- set pkg_install_cmd = '' %}

{%- elif grains['os_family'] == 'Debian' %}

{%- set install_heartbeat = true %}
{%- set heartbeat_url = 'https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-7.3.0-amd64.deb' %}
{%- set heartbeat_hash = '050a1c3085606289f53a4e69fa17fcc3c878f01dbb98363e366a051ad65714d79402d276853065f32ca136ff4eb25fae48c6b21c6d9a18d845763c4d81fec9e9' %}
{%- set heartbeat_path = '/tmp/heartbeat-7.3.0-amd64.deb'  %}
{%- set pkg_install_cmd = 'dpkg -i' %}

{%- elif grains['os_family'] == 'RedHat' %}

{%- set install_heartbeat = true %}
{%- set elastic_gpg_key_url = 'https://packages.elastic.co/GPG-KEY-elasticsearch' %}
{%- set heartbeat_url = 'https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-7.3.0-x86_64.rpm' %}
{%- set heartbeat_hash = 'fa01094e69433308cc69b21d0fbe155d62c8e6dbcbbfc8724509b04fcc63a7471ed3c5af087a85c0b3fd40bd7f6d762877333150c8623dd3b12edfb0a063c2ce' %}
{%- set heartbeat_path = '/tmp/heartbeat-7.3.0-x86_64.rpm'  %}
{%- set pkg_install_cmd = 'rpm -vi' %}
{%- set pkg_check_installed_cmd = 'rpm -q heartbeat-elastic' %}

{%- elif grains['os_family'] == 'MacOS' %}

{%- set install_heartbeat = true %}

{%- else %}

{%- set install_heartbeat = false %}

{%- endif %}

{%- if install_heartbeat %}
  {%- if grains['os_family'] == 'RedHat' %}
heartbeat-rpm-gpg-key:
  cmd.run:
    - name: 'rpm --import {{ elastic_gpg_key_url }}'
    - require_in:
      - file: download-heartbeat
  {%- endif %}

  {%- if not grains['os_family'] == 'MacOS' %}
download-heartbeat:
  file.managed:
    - name: {{ heartbeat_path }}
    - source: {{ heartbeat_url }}
    - source_hash: {{ heartbeat_hash }}
    - unless: '[ -f {{ heartbeat_path }} ]'
  {%- endif %}

  {%- if grains['os'] == 'Windows' %}
unzip-heartbeat:
  archive.unzip:
    - name: 'C:\Program Files\Heartbeat'
    - source: {{ heartbeat_path }}
  {%- endif %}


  {%- if not grains['os_family'] == 'MacOS' %}
install-heartbeat:
  cmd.run:
    {%- if grains['os'] == 'Windows' %}
    - name: 'powershell -ExecutionPolicy UnRestricted -File C:\Program Files\Heartbeat\install-service-heartbeat.ps1'
    - require:
      - unzip-heartbeat
      - download-heartbeat
    {%- else %}
    - name: {{ pkg_install_cmd}} {{ heartbeat_path }}
    - require:
      - download-heartbeat
    {%- endif %}
    {%- if pkg_check_installed_cmd is defined %}
    - unless: {{ pkg_check_installed_cmd }}
    {%- endif %}
  {%- else %}
install-heartbeat:
  module.run:
    - name: pkg.install
    - m_name: elastic/tap/heartbeat-full
    - tap: elastic/tap
  {%- endif %}

heartbeat-config:
  file.managed:
  {%- if grains['os'] == 'Windows' %}
    - name: c:\Program Files\Heartbeat\heartbeat.yml
    - contents: |
        heartbeat.monitors:
        - type: tcp
          name: HOSTNAMEVALUE-localhost-winrm-5985
          schedule: '@every 5s'
          hosts: ["localhost:5985"]
        processors:
        - add_cloud_metadata:
            overwrite: true
        - add_host_metadata:
            netinfo.enabled: true
        - add_fields:
            fields:
              account: ci
            target: aws
        - add_fields:
            target: test
            fields:
              pyver: PYVERVALUE
              transport: TRANSPORTVALUE
              buildnumber: 99999
              buildname: BUILDNAMEVALUE
  {%- else %}
    {%- if grains['os_family'] == 'MacOS' %}
    - name: /usr/local/etc/heartbeat/heartbeat.yml
    - user: root
    - group: wheel
    {%- else %}
    - name: /etc/heartbeat/heartbeat.yml
    {%- endif %}
    - contents: |
        heartbeat.monitors:
        - type: tcp
          name: HOSTNAMEVALUE-localhost-ssh-22
          schedule: '@every 5s'
          hosts: ["localhost:22"]
        processors:
        - add_cloud_metadata:
            overwrite: true
        - add_host_metadata:
            netinfo.enabled: true
        - add_fields:
            fields:
              account: ci
            target: aws
        - add_fields:
            target: test
            fields:
              pyver: PYVERVALUE
              transport: TRANSPORTVALUE
              buildnumber: 99999
              buildname: BUILDNAMEVALUE
  {%- endif %}

  {%- if not grains['os_family'] == 'MacOS' %}
heartbeat-elastic:
  service.disabled
  {%- endif %}
{%- endif %}
