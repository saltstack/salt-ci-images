{%- if grains['os'] in ('Amazon',) %}
download-epel-release:
  cmd.run:
    - name: yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

{%- else %}
{%- if grains['os'] == 'CentOS Stream' %}
download-epel-release:
  cmd.run:
    - name: dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-{{ grains['osmajorrelease'] }}.noarch.rpm
{%- else %}
epel-release:
  pkg.installed
{%- endif %}
{%- endif %}
