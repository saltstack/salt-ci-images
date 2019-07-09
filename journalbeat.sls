{%- set journalbeat_url = 'https://artifacts.elastic.co/downloads/beats/journalbeat/journalbeat-7.2.0-amd64.deb' %}
{%- set journalbeat_hash = '8c0cdb3e51078a97a214e5de07d22f165ceac83d19e88aa90b247b40bc4d3b5549ad31a9f32103ed2d55f55cc8c51ac519f72c4ce71345487bff3dd475fd7629' %}
{%- set journalbeat_path = '/tmp/journalbeat-7.2.0-amd64.deb'  %}
{%- set pkg_install_cmd = 'dpkg -i' %}


download-journalbeat:
  file.managed:
    - name: {{ journalbeat_path }}
    - source: {{ journalbeat_url }}
    - source_hash: {{ journalbeat_hash }}


journalbeat:
  cmd.run:
    {%- if grains['os'] == 'Windows' %}
    - name: 'powershell -ExecutionPolicy UnRestricted -File C:\Program Files\Filebeat\install-service-journalbeat.ps1'
    - require:
      - unzip-journalbeat
      - download-journalbeat
    {%- else %}
    - name: {{ pkg_install_cmd}} {{ journalbeat_path }}
    - require:
      - download-journalbeat
    {%- endif %}

journalbeat-config:
  file.managed:
    - name: /etc/journalbeat/journalbeat.yml
    - contents: |
        output.logstash:
          hosts:
          - logstash.saltstack.net:5044
