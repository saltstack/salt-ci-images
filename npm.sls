{% set suse = True if grains['os_family'] == 'Suse' else False %}
{% set freebsd = True if grains['os'] == 'FreeBSD' else False %}
{% set fedora = True if grains['os'] == 'Fedora' else False %}
{% set macos = True if grains['os'] == 'MacOS' else False %}

{% set fedora24 = True if fedora and grains['osrelease'] == '24' else False %}

# Suse does not package npm separately
{% if suse %}
  {%- set npm = 'npm4' %}
  {%- set nodejs = 'nodejs4' %}
{% elif freebsd %}
  {%- set npm = 'www/npm' %}
{% elif macos %}
  {%- set npm = 'node' %}
{% else %}
  {%- set npm = 'npm' %}
{% endif %}


npm:
  pkg.installed:
    pgks:
{% if suse %} 
    - {{ npm }}
    - {{ nodejs }}
{% else %}
    - {{ npm }}
    - aggregate: True
{% endif %}
