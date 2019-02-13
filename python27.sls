{%- if grains['os'] == 'Windows' %}
  {%- set python2 = 'python2_x86' %}
{%- else %}
  {%- set python2 = 'python2' %}
{%- endif %}

python2:
  pkg.latest:
    - name: {{ python2 }}
