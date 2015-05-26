{% if grains['os_family'] == 'RedHat' %}
  {% set pyopenssl = 'pyOpenSSL' %}
{% elif grains['os_family'] in ['Debian', 'Suse'] %}
  {% set pyopenssl = 'python-openssl' %}
{% elif grains['os'] == 'Arch' %}
  {% set pyopenssl = 'python2-pyopenssl' %}
{% endif %}

pyopenssl:
  pkg.installed:
    - name: {{ pyopenssl }}
