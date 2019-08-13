{%- if grains['os'] == 'Windows' %}

{%- set install_metricbeat = true %}
{%- set metricbeat_url = 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.3.0-windows-x86_64.zip' %}
{%- set metricbeat_hash = 'ba02c1eb3820100b5d0cffd5b101bebd7392c3b60826d9bb47bbde2dc9191d50aa71382e3f38c2292d19ca6689b65bffbedc67bca084fa3fe2d067cc68a7dc4b' %}
{%- set metricbeat_path = 'c:\\metricbeat-7.3.0-windows-x86_64.zip'  %}
# Unused on windows
{%- set pkg_install_cmd = '' %}

{%- elif grains['os_family'] == 'Debian' %}

{%- set install_metricbeat = true %}
{%- set metricbeat_url = 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.3.0-amd64.deb' %}
{%- set metricbeat_hash = 'ca655d5245c869c18d0fd9995573766f841c91b3aa6b1459ba87a60606086f9e90ee562794948a070e14382424721e1ffb73cd234f91806ce103ef9cc3d4b1ab' %}
{%- set metricbeat_path = '/tmp/metricbeat-7.3.0-amd64.deb'  %}
{%- set pkg_install_cmd = 'dpkg -i' %}

{%- elif grains['os_family'] == 'RedHat' %}

{%- set install_metricbeat = true %}
{%- set elastic_gpg_key_url = 'https://packages.elastic.co/GPG-KEY-elasticsearch' %}
{%- set metricbeat_url = 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.3.0-x86_64.rpm' %}
{%- set metricbeat_hash = 'e25e8a8061af9bd39e6f5a74354eb88b44c69607b80b71b5012da776eeac0188c2de5179ed14dabb7384b6e28c2a24cd46f6cd826b0f8051c2478cab9c53da61' %}
{%- set metricbeat_path = '/tmp/metricbeat-7.3.0-x86_64.rpm'  %}
{%- set pkg_install_cmd = 'rpm -vi' %}
{%- set pkg_check_installed_cmd = 'rpm -q metricbeat' %}

{%- elif grains['os_family'] == 'MacOS' %}

{%- set install_metricbeat = true %}

{%- else %}

{%- set install_metricbeat = false %}

{%- endif %}

{%- if install_metricbeat %}
  {%- if grains['os_family'] == 'RedHat' %}
metricbeat-rpm-gpg-key:
  cmd.run:
    - name: 'rpm --import {{ elastic_gpg_key_url }}'
    - require_in:
      - file: download-metricbeat
  {%- endif %}

  {%- if not grains['os_family'] == 'MacOS' %}
download-metricbeat:
  file.managed:
    - name: {{ metricbeat_path }}
    - source: {{ metricbeat_url }}
    - source_hash: {{ metricbeat_hash }}
    - unless: '[ -f {{ metricbeat_path }} ]'
  {%- endif %}

  {%- if grains['os'] == 'Windows' %}
unzip-metricbeat:
  archive.extracted:
    - name: 'C:\Program Files\Metricbeat'
    - source: {{ metricbeat_path }}
  {%- endif %}


  {%- if not grains['os_family'] == 'MacOS' %}
install-metricbeat:
  cmd.run:
    {%- if grains['os'] == 'Windows' %}
    - name: 'powershell -ExecutionPolicy UnRestricted -File C:\Program Files\Metricbeat\install-service-metricbeat.ps1'
    - require:
      - unzip-metricbeat
      - download-metricbeat
    {%- else %}
    - name: {{ pkg_install_cmd}} {{ metricbeat_path }}
    - require:
      - download-metricbeat
    {%- endif %}
    {%- if pkg_check_installed_cmd is defined %}
    - unless: {{ pkg_check_installed_cmd }}
    {%- endif %}
  {%- else %}
install-metricbeat:
  module.run:
    - name: pkg.install
    - m_name: elastic/tap/metricbeat-full
    - tap: elastic/tap
  {%- endif %}

metricbeat-config:
  file.managed:
  {%- if grains['os'] == 'Windows' %}
    - name: c:\Program Files\Metricbeat\metricbeat.yml
    - contents: |
        metricbeat.modules:
        - module: system
          metricsets:
            - cpu
            - load
            - memory
            - network
            - process
            - process_summary
            - uptime
            - socket_summary
            - diskio
            - filesystem
          enabled: true
          period: 10s
          processes: ['.*']
          cpu.metrics:  ["percentages"]
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
    - name: /usr/local/etc/metricbeat/metricbeat.yml
    - user: root
    - group: wheel
    {%- else %}
    - name: /etc/metricbeat/metricbeat.yml
    {%- endif %}
    - contents: |
        metricbeat.config.modules:
          enabled: true
          path: ${path.config}/modules.d/*.yml
        metricbeat.modules:
        - module: system
          metricsets:
            - cpu
            - load
            - memory
            - network
            - process
            - process_summary
            - uptime
            - socket_summary
            - diskio
            - filesystem
          enabled: true
          period: 10s
          processes: ['.*']
          cpu.metrics:  ["percentages"]
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
metricbeat:
  service.disabled
  {%- endif %}
{%- endif %}
