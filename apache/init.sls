{%- if grains['os_family'] == 'RedHat' %}
  {% set apache = 'httpd' %}
{%- else %}
  {% set apache = 'apache2' %}
{%- endif %}

{{ apache }}:
  pkg:
    - installed
  service:
    - running
    {%- if grains['os_family'] == 'RedHat' %}
    - file: /etc/httpd/conf/httpd.conf
    {%- endif %}
    - require:
      - pkg: {{ apache }}

{%- if grains['os_family'] == 'RedHat' and not grains['osmajorrelease'].startswith('7') %}
/etc/httpd/conf/httpd.conf:
  file.managed:
    - source: salt://apache/httpd.conf
    - user: root
    - group: root
    - mode: 644
{%- endif %}
