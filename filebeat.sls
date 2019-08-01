{%- if grains['os'] == 'Windows' %}

{%- set install_filebeat = true %}
{%- set filebeat_url = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.2.0-windows-x86_64.zip' %}
{%- set filebeat_hash = 'dd5f53ab086a2d93705cd6d82d9d6e7e4edf67fc9abede8819272cc5a65d8a54' %}
{%- set filebeat_path = 'c:\\filebeat-7.2.0-windows-x86_64.zip'  %}
# Unused on windows
{%- set pkg_install_cmd = '' %}

{%- elif grains['os_family'] == 'Debian' %}

{%- set install_filebeat = true %}
{%- set filebeat_url = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.2.0-amd64.deb' %}
{%- set filebeat_hash = 'a630f7e2a163aff496e2114b4769025f41500bee09c134e2505b44288ac3866ac0b3c370dcc36a7814ec02dcb2182fed24d5425b4fb0e05c4c9c04cc26490d4f' %}
{%- set filebeat_path = '/tmp/filebeat-7.2.0-amd64.deb'  %}
{%- set pkg_install_cmd = 'dpkg -i' %}

{%- elif grains['os_family'] == 'RedHat' %}

{%- set install_filebeat = true %}
{%- set elastic_gpg_key_url = 'https://packages.elastic.co/GPG-KEY-elasticsearch' %}
{%- set filebeat_url = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.2.0-x86_64.rpm' %}
{%- set filebeat_hash = 'a14fa839b9501f825993d11b202a17fceb345d2de278fc33ffc6be47a3db4df174b4ab0cc0245e1f6ee4a98fe3dc3425e7467b81843eca315bab15accc9b0205' %}
{%- set filebeat_path = '/tmp/filebeat-7.2.0-x86_64.rpm'  %}
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
        cloud.auth: "beats_system:*QT3@-jQ*VHch!K7Towv"
        cloud.id: "prod:dXMtd2VzdC0yLmF3cy5mb3VuZC5pbyRmNGVjMTRlYTIzZGE0Yjc3YjUyNmU2NTU5NzUyMDRjOSQzNjQ3MWViMGRkMTg0MWE0OGU5OTEyMjcyODA5OGM3ZQ=="
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
        cloud.auth: "beats_system:*QT3@-jQ*VHch!K7Towv"
        cloud.id: "prod:dXMtd2VzdC0yLmF3cy5mb3VuZC5pbyRmNGVjMTRlYTIzZGE0Yjc3YjUyNmU2NTU5NzUyMDRjOSQzNjQ3MWViMGRkMTg0MWE0OGU5OTEyMjcyODA5OGM3ZQ=="
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
{%- endif %}

filebeat:
  service.running:
    - enable: True
{%- endif %}
