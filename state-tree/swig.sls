
swig:
  pkg.installed:
    - pkgs:
    {%- if grains['os_family'] == 'FreeBSD' %}
      - swig30
    {%- else %}
      - swig
    {%- endif %}
      - aggregate: True
