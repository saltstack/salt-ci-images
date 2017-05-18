{%- if grains['os'] in ('Windows') %}
c:\\kitchen:
{%- else %}
/usr/bin/kitchen:
{%- endif %}
  file.managed:
    - source: salt://kitchen/kitchen.py
    - template: jinja
{%- if grains['os'] not in ('Windows') %}
    - mode: 755
{%- endif %}
