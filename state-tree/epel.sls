{%- if grains['os'] in ('Amazon',) %}
download-epel-release:
  cmd.run:
    - name: yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

{%- else %}
epel-release:
  pkg.installed
{%- endif %}
