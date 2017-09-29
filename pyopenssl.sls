{% if grains['os'] == 'Fedora' and salt.grains.get('osmajorrelease')|int >= 26 %}
    {%- if pillar.get('py3', False) %}
      {% set pyopenssl = 'python3-pyOpenSSL' %}
    {%- else %}
      {% set pyopenssl = 'python2-pyOpenSSL' %}
    {%- endif %}
{% elif grains['os_family'] in ('RedHat', 'MacOS', 'Windows') %}
  {% set pyopenssl = 'pyOpenSSL' %}
{% elif grains['os_family'] == 'Suse' %}
  {% set pyopenssl = 'python-pyOpenSSL' %}
{% elif grains['os_family'] == 'Debian' %}
  {% if grains['osrelease'].startswith('8') %}
    {% set pyopenssl = 'pyOpenSSL==0.13' %}
  {% else %}
    {% set pyopenssl = 'python-openssl' %}
  {% endif %}
{% elif grains['os'] == 'Arch' %}
  {% set pyopenssl = 'python2-pyopenssl' %}
{% elif grains['os'] == 'FreeBSD' %}
  {% set pyopenssl = 'security/py-openssl' %}
{% endif %}

{% if grains['os'] in ('MacOS', 'Windows') or (grains['os_family'] == 'Debian' and grains['osrelease'].startswith('8')) %}
  {% set install_method = 'pip.installed' %}
{% else %}
  {% set install_method = 'pkg.installed' %}
{% endif %}

pyopenssl:
  {{ install_method }}:
    - name: {{ pyopenssl }}
    {%- if install_method == 'pkg.installed' %}
    - aggregate: True
    {%- endif %}
    {%- if grains['os_family'] in ('MacOS',) %}
    {# MacOS needs to upgrade to the newest since we install the newest OpenSSL from Brew #}
    - upgrade: True
    {%- endif %}
