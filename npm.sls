{% if grains['kernel'] == 'Linux' %}

# Suse does not package npm separately
{% if grains['os_family'] in ('Suse', 'Arch') %}
  {%- set npm = 'nodejs' %}
{% else %}
  {%- set npm = 'npm' %}
{% endif %}


{%- if grains['os'] == 'openSUSE' %}
install-suse-repo:
  cmd.run:
    - name: zypper --non-interactive addrepo --refresh http://download.opensuse.org/repositories/devel:/languages:/nodejs/openSUSE_13.1/devel:languages:nodejs.repo
{% endif %}


npm:
  pkg.installed:
    - name: {{ npm }}

{% endif %}
