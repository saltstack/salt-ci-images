{%- if grains['os'] == 'Windows' %}

{%- set metricbeat_url = 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.2.0-windows-x86_64.zip' %}
{%- set metricbeat_hash = '341eb34fbe361cab146f80c198dc4b05e3211e8a16b9b190e8c83ce5a997a072233b4f1cab59170e2884845b0b339dee48be32b34a89101d7e302a4423e0d18b' %}
{%- set metricbeat_path = 'c:\\metricbeat-7.2.0-windows-x86_64.zip'  %}
# Unused on windows
{%- set pkg_install_cmd = '' %}

{%- else %}

{%- set metricbeat_url = 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.2.0-amd64.deb' %}
{%- set metricbeat_hash = 'e4cee5c74cfecd73353b721f00df41d76c08174ac5f1f3e827aab205183ea421942fa83c345a36b36f1a53efc59f3f466acce649f1b0a90dd590d2d6aa3f5bde' %}
{%- set metricbeat_path = '/tmp/metricbeat-7.2.0-amd64.deb'  %}
{%- set pkg_install_cmd = 'dpkg -i' %}

{%- endif %}

download-metricbeat:
  file.managed:
    - name: {{ metricbeat_path }}
    - source: {{ metricbeat_url }}
    - source_hash: {{ metricbeat_hash }}

{%- if grains['os'] == 'Windows' %}
unzip-metricbeat:
  archive.extract:
    - name: 'C:\Program Files\Metricbeat'
    - source: {{ metricbeat_path }}
{%- endif %}

metricbeat:
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

metricbeat-config:
  file.managed:
{%- grains['os'] == 'Windows' %}
    - name: c:\Program Files\Filebeat\metricbeat.yml
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
           - fsstat
         enabled: true
         period: 10s
         processes: ['.*']
       processors:
         - add_fields:
             target: test
             fields:
               pyver: PYVERVALUE
               transport: TRANSPORTVALUE
               commitid: COMMITIDVALUE
               buildnumber: BUILDNUMBERVALUE
               buildname: BUILDNAMEVALUE
       metricbeat.config.modules:
         path: ${path.config}\\modules.d\\*.yml
         reload.enabled: true
         reload.period: 10s
       output.logstash:
         hosts:
         - logstash.saltstack.net:5044
{%- else %}
    - name: /etc/metricbeat/metricbeat.yml
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
           - fsstat
           - socket
         enabled: true
         period: 10s
         processes: ['.*']
       processors:
         - add_fields:
             target: test
             fields:
               pyver: PYVERVALUE
               transport: TRANSPORTVALUE
               commitid: COMMITIDVALUE
               buildnumber: BUILDNUMBERVALUE
               buildname: BUILDNAMEVALUE
       metricbeat.config.modules:
         path: ${path.config}/modules.d/*.yml
         reload.enabled: true
         reload.period: 10s
       output.logstash:
         hosts:
         - logstash.saltstack.net:5044
{%- endif %}
