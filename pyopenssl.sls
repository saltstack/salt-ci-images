{% if grains['os_family'] == 'RedHat' %}
  {% set pyopenssl = 'pyOpenSSL' %}
{% elif grains['os_family'] == 'Suse' %}
  {% set pyopenssl = 'python-pyOpenSSL' %}
{% elif grains['os_family'] == 'Debian' %}
  {% set pyopenssl = 'python-openssl' %}
{% elif grains['os'] == 'Arch' %}
  {% set pyopenssl = 'python2-pyopenssl' %}
{% elif grains['os'] == 'FreeBSD' %}
  {% set pyopenssl = 'security/py-openssl' %}
{% endif %}

pyopenssl:
  pkg.installed:
    - name: {{ pyopenssl }}
