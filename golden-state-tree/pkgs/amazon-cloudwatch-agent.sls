{%- if grains['os'] == 'Windows' %}
  {%- set download_url = "https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/amazon-cloudwatch-agent.msi" %}
{%- elif grains['os'] == 'MacOS' %}
  {%- set download_url = "https://s3.amazonaws.com/amazoncloudwatch-agent/darwin/amd64/latest/amazon-cloudwatch-agent.pkg" %}
  {%- set download_path = "/tmp/amazon-cloudwatch-agent.pkg" %}
{%- else %}
  {%- if grains['cpuarch'].lower() == 'x86_64' %}
    {% set arch = "amd64" %}
  {%- else %}
    {%- set arch = "arm64" %}
  {%- endif %}
  {%- if grains['os_family'] in ('RedHat', 'Suse') %}
    {%- set extension = "rpm" %}
  {%- else %}
    {%- set extension = "deb" %}
  {%- endif %}
  {%- set download_url = "https://amazoncloudwatch-agent.s3.amazonaws.com/nightly-build/latest/linux/" + arch + "/amazon-cloudwatch-agent." + extension %}
  {%- set download_path = "/tmp/amazon-cloudwatch-agent." + extension %}
{%- endif %}


{%- if grains['os'] != 'Windows' %}
download-amazon-cloudwatch-agent:
  file.managed:
    - name: {{ download_path }}
    - source: {{ download_url }}
    - skip_verify: true
{%- endif %}

{%- if grains['os_family'] == 'Arch' %}
debtap:
  pkg.installed

build-arch-package:
  cmd.run:
    - name: debtap {{ download_path }}
    - require:
      - debtap
{%- endif %}

install-amazon-cloudwatch-agent:
  cmd.run:
    {%- if grains['os'] == 'Windows' %}
    - name: msiexec.exe /i {{ download_url }} /qn /L*v C:\CloudwatchInstall.log
    {%- elif grains['os'] == 'MacOS' %}
    - name: installer -pkg {{ download_path }} -target /
    {%- elif grains['os_family'] in ('RedHat', 'Suse') %}
    - name: rpm -U {{ download_path }}
    {%- elif grains['os_family'] == 'Debian' %}
    - name: dpkg -i -E {{ download_path }}
    {%- elif grains['os_family'] == 'Arch' %}
    - name: pacman -U {{ download_path.replace('.deb', '.zst') }}
    {%- endif %}
    {%- if grains['os'] != 'Windows' %}
    - require:
      - download-amazon-cloudwatch-agent
      {%- if grains['os_family'] == 'Arch' %}
      - build-arch-package
      {%- endif %}
    {%- endif %}
