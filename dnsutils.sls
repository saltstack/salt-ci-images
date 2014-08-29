# Various bind packages are needed to run dig tests
{% if grains['os_family'] in ('RedHat', 'Suse') %}
  {% set dnsutils = 'bind-utils' %}
{% elif grains['os'] == 'Gentoo' %}
  {% set dnsutils = 'bind-tools' %}
{% elif grains['os_family'] == 'FreeBSD' %}
  {% set dnsutils = 'dns/bind-tools' %}
{% else %}
  {% set dnsutils = 'dnsutils' %}
{% endif %}

dnsutils:
  pkg.installed:
    - name: {{ dnsutils }}
