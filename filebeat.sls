{%- if grains['os'] == 'Windows' %}

{%- set install_filebeat = true %}
{%- set filebeat_url = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.3.0-windows-x86_64.zip' %}
{%- set filebeat_hash = '525d536dfc18218fb5c6a6e84a40b385c3c779d4ab0cee95eaee3c23449d21e8712fa95f83522cc100396dd2321637e2927c7d2507295ee421856c81fecf8249' %}
{%- set filebeat_path = 'c:\\filebeat-7.3.0-windows-x86_64.zip'  %}
# Unused on windows
{%- set pkg_install_cmd = '' %}

{%- elif grains['os_family'] == 'Debian' %}

{%- set install_filebeat = true %}
{%- set filebeat_url = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.3.0-amd64.deb' %}
{%- set filebeat_hash = 'dcdbf53ade1c1df29a96c661d9e10d75983b8b0621f852c3c48f325928a694d30e99680ade4edeefd1bfc4ed58e9b39d513091a55815f494d7ff7c197c538b16' %}
{%- set filebeat_path = '/tmp/filebeat-7.3.0-amd64.deb'  %}
{%- set pkg_install_cmd = 'dpkg -i' %}

{%- elif grains['os_family'] == 'RedHat' %}

{%- set install_filebeat = true %}
{%- set elastic_gpg_key_url = 'https://packages.elastic.co/GPG-KEY-elasticsearch' %}
{%- set filebeat_url = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.3.0-x86_64.rpm' %}
{%- set filebeat_hash = 'b2c327df5278960af2bef7a7bf4598ec833f57fbd6ba381829ad33b500123e9663c7fa8a6ec0d7bada77391618fc64ec1fe94393efb780edb077dd8fad39ed13' %}
{%- set filebeat_path = '/tmp/filebeat-7.3.0-x86_64.rpm'  %}
{%- set pkg_install_cmd = 'rpm -vi' %}
{%- set pkg_check_installed_cmd = 'rpm -q filebeat' %}

{%- else %}

{%- set install_filebeat = false %}

{%- endif %}

{%- if install_filebeat %}
{%- if grains['os_family'] == 'RedHat' %}
filebeat-rpm-gpg-key:
  cmd.run:
    - name: 'rpm --import {{ elastic_gpg_key_url }}'
    - require_in:
      - file: download-filebeat
{%- endif %}

download-filebeat:
  file.managed:
    - name: {{ filebeat_path }}
    - source: {{ filebeat_url }}
    - source_hash: {{ filebeat_hash }}
    - unless: '[ -f {{ filebeat_path }} ]'

{%- if grains['os'] == 'Windows' %}
unzip-filebeat:
  archive.unzip:
    - name: 'C:\Program Files\Filebeat'
    - source: {{ filebeat_path }}
{%- endif %}

install-filebeat:
  cmd.run:
    {%- if grains['os'] == 'Windows' %}
    - name: 'powershell -ExecutionPolicy UnRestricted -File C:\Program Files\Filebeat\install-service-filebeat.ps1'
    - require:
      - unzip-filebeat
      - download-filebeat
    {%- else %}
    - name: {{ pkg_install_cmd}} {{ filebeat_path }}
    - require:
      - download-filebeat
    {%- endif %}
    {%- if pkg_check_installed_cmd is defined %}
    - unless: {{ pkg_check_installed_cmd }}
    {%- endif %}

filebeat-config:
  file.managed:
{%- if grains['os'] == 'Windows' %}
    - name: c:\Program Files\Filebeat\filebeat.yml
    - contents: |
        filebeat.inputs:
          - type: log
            paths:
              - c:\\kitchen\\testing\\**\\*.log
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
    - name: /etc/filebeat/filebeat.yml
    - contents: |
        filebeat.config.modules:
          enabled: true
          path: ${path.config}/modules.d/*.yml
        filebeat.inputs:
          - type: log
            paths:
              - /tmp/kitchen/testing/artifacts/logs/*.log
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

filebeat-enable-system-module:
  cmd.run:
    - name: filebeat modules enable system
    - unless: test -f /etc/filebeat/modules.d/system.yml
    - require:
      - cmd: install-filebeat
{%- endif %}

filebeat:
  service.disabled
{%- endif %}
