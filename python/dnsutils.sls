# Various bind packages are needed to run dig tests
{% if grains['os_family'] == 'RedHat' %}
  {% set dnsutils = 'bind-utils' %}
{% elif grains['os'] == 'Gentoo' %}
  {% set dnsutils = 'bind-tools' %}
{% else %}
  {% set dnsutils = 'dnsutils' %}
{% endif %}

dnsutils:
  pkg.installed:
    - name: {{ dnsutils }}
    