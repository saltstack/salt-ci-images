{% if grains['kernel'] == 'Linux' %}

# Suse does not package npm separately
{% if grains['os_family'] == 'Suse' %}
{% set npm = 'nodejs' %}
{% else %}
{% set npm = 'npm' %}
{% endif %}

{{ npm }}:
  pkg.installed

{% endif %}
