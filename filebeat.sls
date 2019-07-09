{%- if grains['os'] == 'Windows' %}

{%- set filebeat_url = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.2.0-windows-x86_64.zip' %}
{%- set filebeat_hash = 'dd5f53ab086a2d93705cd6d82d9d6e7e4edf67fc9abede8819272cc5a65d8a54' %}
{%- set filebeat_path = 'c:\\filebeat-7.2.0-windows-x86_64.zip'  %}
# Unused on windows
{%- set pkg_install_cmd = '' %}

{%- else %}

{%- set filebeat_url = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.2.0-amd64.deb' %}
{%- set filebeat_hash = 'cba97c27cf981d7d414a36545f562de0a36c1e10556f939dfe431736a51c641b' %}
{%- set filebeat_path = '/tmp/filebeat-7.2.0-amd64.deb'  %}
{%- set pkg_install_cmd = 'dpkg -i' %}

{%- endif %}

download-filebeat:
  file.managed:
    - name: {{ filebeat_path }}
    - source: {{ filebeat_url }}
    - source_hash: {{ filebeat_hash }}

{%- if grains['os'] == 'Windows' %}
unzip-filebeat:
  archive.extract:
    - name: 'C:\Program Files\Filebeat'
    - source: {{ filebeat_path }}
{%- endif %}

filebeat:
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

filebeat-config:
  file.managed:
{%- grains['os'] == 'Windows' %}
    - name: c:\Program Files\Filebeat\filebeat.yml
    - contents: |
        filebeat.inputs:
          - type: log
            paths:
              - c:\\kitchen\\testing\\**\\*.log
        processors:
          - add_fields:
              target: test
              fields:
                pyver: PYVERVALUE
                transport: TRANSPORTVALUE
                commitid: COMMITIDVALUE
                buildnumber: BUILDNUMBERVALUE
                buildname: BUILDNAMEVALUE
        filebeat.config.inputs:
          enabled: true
          path: c:\Program Files\Filebeat\filebeat.yml
          reload.enabled: true
          reload.period: 10s
        output.logstash:
          hosts:
          - logstash.saltstack.net:5044
{%- else %}
    - name: /etc/filebeat/filebeat.yml
    - contents: |
        filebeat.inputs:
          - type: log
            paths:
              - /tmp/kitchen/testing/**/*.log
              - /var/log/**
        processors:
          - add_fields:
              target: test
              fields:
                pyver: PYVERVALUE
                transport: TRANSPORTVALUE
                commitid: COMMITIDVALUE
                buildnumber: BUILDNUMBERVALUE
                buildname: BUILDNAMEVALUE
        filebeat.config.inputs:
          enabled: true
          path: /etc/filebeat/filebeat.yml
          reload.enabled: true
          reload.period: 10s
        output.logstash:
          hosts:
          - logstash.saltstack.net:5044
{%- endif %}
