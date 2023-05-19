{%- if grains['os_family'] == 'Debian' %}
  {%- set libffi = "libffi-dev" %}
{%- elif grains['os'] in ['VMware Photon OS'] or grains["os_family"] in ("RedHat", "Suse") %}
  {%- set libffi = "libffi-devel" %}
{%- else %}
  {%- set libffi = "libffi" %}
{%- endif %}

libffi:
  pkg.installed:
    - name: {{ libffi }}
