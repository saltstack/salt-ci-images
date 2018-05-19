{% if grains['os'] in ('CentOS',) %}
winrm:
  pkg.installed:
    - name: python2-winrm
{% endif %}
