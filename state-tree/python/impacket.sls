{%- if grains['os'] in ('CentOS',) %}
impacket:
  pkg.installed:
    - name: python2-impacket
{%- endif %}
