{%- if grains['os'] == 'Windows' %}
  {%- set download_url = "https://awscli.amazonaws.com/AWSCLIV2.msi" %}
{%- elif grains['os'] == 'MacOS' %}
  {%- set download_url = "https://awscli.amazonaws.com/AWSCLIV2.pkg" %}
{%- else %}
  {%- if grains['cpuarch'].lower() == 'x86_64' %}
    {%- set download_url = "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" %}
  {%- else %}
    {%- set download_url = "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" %}
  {%- endif %}
{%- endif %}

{%- if grains['os'] == 'MacOS' %}
download-awscli:
  file.managed:
    - name: /tmp/AWSCLIV2.pkg
    - source: {{ download_url }}
    - skip_verify: true
{%- elif grains['os'] != 'Windows' %}
download-awscli:
  archive.extracted:
    - name: /tmp/
    - source: {{ download_url }}
    - skip_verify: true
    - archive_format: zip
    - enforce_toplevel: False
{%- endif %}

awscli:
  cmd.run:
{%- if grains['os'] == 'Windows' %}
    - name: msiexec.exe /i {{ download_url }}
{%- else %}
  {%- if grains['os'] == 'MacOS' %}
    - name: installer -pkg /tmp/AWSCLIV2.pkg -target /
  {%- else %}
    - name: /tmp/aws/install
  {%- endif %}
    - require:
      - download-awscli
{%- endif %}
