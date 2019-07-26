{%- if grains['os'] == 'Windows' %}

{%- set install_metricbeat = true %}
{%- set metricbeat_url = 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.2.0-windows-x86_64.zip' %}
{%- set metricbeat_hash = '341eb34fbe361cab146f80c198dc4b05e3211e8a16b9b190e8c83ce5a997a072233b4f1cab59170e2884845b0b339dee48be32b34a89101d7e302a4423e0d18b' %}
{%- set metricbeat_path = 'c:\\metricbeat-7.2.0-windows-x86_64.zip'  %}
# Unused on windows
{%- set pkg_install_cmd = '' %}

{%- elif grains['os_family'] == 'Debian' %}

{%- set install_metricbeat = true %}
{%- set metricbeat_url = 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.2.0-amd64.deb' %}
{%- set metricbeat_hash = 'e4cee5c74cfecd73353b721f00df41d76c08174ac5f1f3e827aab205183ea421942fa83c345a36b36f1a53efc59f3f466acce649f1b0a90dd590d2d6aa3f5bde' %}
{%- set metricbeat_path = '/tmp/metricbeat-7.2.0-amd64.deb'  %}
{%- set pkg_install_cmd = 'dpkg -i' %}

{%- elif grains['os_family'] == 'RedHat' %}

{%- set install_metricbeat = true %}
{%- set elastic_gpg_key_url = 'https://packages.elastic.co/GPG-KEY-elasticsearch' %}
{%- set metricbeat_url = 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.2.0-x86_64.rpm' %}
{%- set metricbeat_hash = '945ad400b5957cd19ac9b81cbc30df5b6ca7b65e24429d67fd08c7ba2791619b3717be2514e198252df6728007becdec21c5a30f316d5d4d9f31a14f3f45be88' %}
{%- set metricbeat_path = '/tmp/metricbeat-7.2.0-x86_64.rpm'  %}
{%- set pkg_install_cmd = 'rpm -vi' %}
{%- set pkg_check_installed_cmd = 'rpm -q metricbeat' %}

{%- else %}

{%- set install_metricbeat = false %}

{%- endif %}

{%- if install_metricbeat %}
{%- if grains['os_family'] == 'RedHat' %}
metricbeat-rpm-gpg-key:
  cmd.run:
    - name: 'rpm --import {{ elastic_gpg_key_url }}'
    - require_in:
      - file: download-filebeat
{%- endif %}

download-metricbeat:
  file.managed:
    - name: {{ metricbeat_path }}
    - source: {{ metricbeat_url }}
    - source_hash: {{ metricbeat_hash }}
    - unless: '[ -f {{ metricbeat_path }} ]'

{%- if grains['os'] == 'Windows' %}
unzip-metricbeat:
  archive.unzip:
    - name: 'C:\Program Files\Metricbeat'
    - source: {{ metricbeat_path }}
{%- endif %}

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

metricbeat-config:
  file.managed:
{%- if grains['os'] == 'Windows' %}
    - name: c:\Program Files\Filebeat\metricbeat.yml
    - contents: |
        metricbeat.modules:
        - module: system
          metricsets:
            - cpu
            - filesystem
            - memory
            - network
            - process
          enabled: true
          period: 10s
          processes: ['.*']
        output.logstash:
          hosts:
          - logstash1.prod.pdx.hub.aws.saltstack.net:5044
          - logstash2.prod.pdx.hub.aws.saltstack.net:5044
          - logstash3.prod.pdx.hub.aws.saltstack.net:5044
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
        xpack.monitoring:
          elasticsearch:
            hosts:
            - elasticsearch1.prod.pdx.hub.aws.saltstack.net:9200
            - elasticsearch2.prod.pdx.hub.aws.saltstack.net:9200
            - elasticsearch3.prod.pdx.hub.aws.saltstack.net:9200
            - elasticsearch4.prod.pdx.hub.aws.saltstack.net:9200
            - elasticsearch5.prod.pdx.hub.aws.saltstack.net:9200
          enabled: true
{%- else %}
    - name: /etc/metricbeat/metricbeat.yml
    - contents: |
        metricbeat.config.modules:
          enabled: true
          path: ${path.config}/modules.d/*.yml
        output.logstash:
          hosts:
          - logstash1.prod.pdx.hub.aws.saltstack.net:5044
          - logstash2.prod.pdx.hub.aws.saltstack.net:5044
          - logstash3.prod.pdx.hub.aws.saltstack.net:5044
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
        xpack.monitoring:
          elasticsearch:
            hosts:
            - elasticsearch1.prod.pdx.hub.aws.saltstack.net:9200
            - elasticsearch2.prod.pdx.hub.aws.saltstack.net:9200
            - elasticsearch3.prod.pdx.hub.aws.saltstack.net:9200
            - elasticsearch4.prod.pdx.hub.aws.saltstack.net:9200
            - elasticsearch5.prod.pdx.hub.aws.saltstack.net:9200
          enabled: true
{%- endif %}

metricbeat:
  service.running:
    - enable: True
{%- endif %}
