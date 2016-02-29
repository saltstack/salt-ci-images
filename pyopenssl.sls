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
{% elif grains['os'] == 'MacOS' %}
  {% set pyopenssl = 'pyOpenSSL' %}
{% endif %}

{% if grains['os'] == 'MacOS' %}
  {# brew does not have pyopenssl, so install with pip #}
  {% set install_method = 'pip.installed' %}
{% else %}
  {% set install_method = 'pkg.installed' %}
{% endif %}

pyopenssl:
  {{ install_method }}:
    - name: {{ pyopenssl }}
