{%- if grains['os'] in ('CentOS',) %}
winexe:
  pkg.installed:
    - name: winexe
    - sources:
      - winexe: https://repo.saltstack.com/yum/redhat/7/x86_64/archive/2017.7.2/winexe-1.1-b787d2.el7.x86_64.rpm
{%- endif %}
