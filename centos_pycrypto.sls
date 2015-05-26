# Until pycrypto>=2.6.1 can be packaged, we need to be able to run the test suite on CentOS 5/6
include:
  - python.pycrypto

{% set os_version = salt['grains.get']('osmajorrelease', '') %}

{% if os_version == '5' %}
  {% set crypto_pkg_name = 'python26-crypto' %}
{% else %}
  {% set crypto_pkg_name = 'python-crypto' %}
{% endif %}

uninstall_system_pycrypto:
  pkg.removed:
    - name: {{ crypto_pkg_name }}
    - require_in:
      - pip: pycrypto
