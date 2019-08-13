{%- if grains['os_family'] == 'Debian' %}

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

{%- elif grains['os_family'] == 'MacOS' %}

{%- set install_filebeat = true %}

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

  {%- if not grains['os_family'] == 'MacOS' %}
download-filebeat:
  file.managed:
    - name: {{ filebeat_path }}
    - source: {{ filebeat_url }}
    - source_hash: {{ filebeat_hash }}
    - unless: '[ -f {{ filebeat_path }} ]'
  {%- endif %}

  {%- if not grains['os_family'] == 'MacOS' %}
install-filebeat:
  cmd.run:
    - name: {{ pkg_install_cmd}} {{ filebeat_path }}
    - require:
      - download-filebeat
    {%- if pkg_check_installed_cmd is defined %}
    - unless: {{ pkg_check_installed_cmd }}
    {%- endif %}
  {%- else %}
install-filebeat:
  module.run:
    - name: pkg.install
    - m_name: elastic/tap/filebeat-full
    - tap: elastic/tap
  {%- endif %}

filebeat-config:
  file.managed:
  {%- if grains['os_family'] == 'MacOS' %}
    - name: /usr/local/etc/filebeat/filebeat.yml
    - user: root
    - group: wheel
  {%- else %}
    - name: /etc/filebeat/filebeat.yml
  {%- endif %}
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

  {%- if 'MacOS' in grains.os_family or grains.osfinger in ['CentOS-6', 'Amazon Linux AMI-2018'] %}
  cmd.run:
    - name: filebeat modules enable system
      {%- if grains['os_family'] == 'MacOS' %}
    - unless: test -f /usr/local/etc/filebeat/modules.d/system.yml
    - require:
      - module: install-filebeat
      {%- else %}
    - unless: test -f /etc/filebeat/modules.d/system.yml
    - require:
      - cmd: install-filebeat
      {%- endif %}
  {%- endif %}

  {%- if not grains['os_family'] == 'MacOS' %}
filebeat:
  service.disabled
  {%- endif %}
{%- endif %}
