{%- if grains['os_family'] == 'Debian' %}

{%- set install_journalbeat = true %}
{%- set journalbeat_url = 'https://artifacts.elastic.co/downloads/beats/journalbeat/journalbeat-7.3.0-amd64.deb' %}
{%- set journalbeat_hash = 'b322d8fc2822dd07a34665660dc988c6267b50519193855fe46b7175ad9fe99e4efa334a2163aa7ce37e282a4fef08597a65f39ddc164a4598173f8adc7c6ac4' %}
{%- set journalbeat_path = '/tmp/journalbeat-7.3.0-amd64.deb'  %}
{%- set pkg_install_cmd = 'dpkg -i' %}
{%- set pkg_check_installed_cmd = 'dpkg -l | grep journalbeat' %}

{%- elif grains['os_family'] == 'RedHat' %}

{%- set install_journalbeat = true %}
{%- set elastic_gpg_key_url = 'https://packages.elastic.co/GPG-KEY-elasticsearch' %}
{%- set journalbeat_url = 'https://artifacts.elastic.co/downloads/beats/journalbeat/journalbeat-7.3.0-x86_64.rpm' %}
{%- set journalbeat_hash = '8ff7c0b79f95028de1623ea3f393a01edb70e2bf49b741462d3d8a39410023806a3ab65279aae67f520353f502a1ca50e0b9772d5e25260601d25ab9f4ba3210' %}
{%- set journalbeat_path = '/tmp/journalbeat-7.3.0-x86_64.rpm'  %}
{%- set pkg_install_cmd = 'rpm -vi' %}
{%- set pkg_check_installed_cmd = 'rpm -q journalbeat' %}

{%- else %}

{%- set install_journalbeat = false %}

{%- endif %}

{%- if install_journalbeat %}
  {%- if grains['os_family'] == 'RedHat' %}
journalbeat-rpm-gpg-key:
  cmd.run:
    - name: 'rpm --import {{ elastic_gpg_key_url }}'
    - require_in:
      - file: download-journalbeat
  {%- endif %}

download-journalbeat:
  file.managed:
    - name: {{ journalbeat_path }}
    - source: {{ journalbeat_url }}
    - source_hash: {{ journalbeat_hash }}
    - unless: '[ -f {{ journalbeat_path }} ]'

install-journalbeat:
  cmd.run:
    - name: {{ pkg_install_cmd}} {{ journalbeat_path }}
    - require:
      - download-journalbeat
    {%- if pkg_check_installed_cmd is defined %}
    - unless: {{ pkg_check_installed_cmd }}
    {%- endif %}

journalbeat-config:
  file.managed:
    - name: /etc/journalbeat/journalbeat.yml
    - contents: |
        journalbeat.inputs:
        - paths: []
          seek: cursor
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
        logging.level: warning

journalbeat:
  service.disabled
{%- endif %}
