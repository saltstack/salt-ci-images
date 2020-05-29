
swig:
  pkg.installed:
    - aggregate: True
    - pkgs:
    {%- if grains['os_family'] == 'FreeBSD' %}
      - swig30
    {%- else %}
      - swig
    {%- endif %}
