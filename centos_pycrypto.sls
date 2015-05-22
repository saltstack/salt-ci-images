# Until pycrypto>=2.6.1 can be packaged, we need to be able to run the test suite on CentOS 5/6

uninstall_system_pycrypto:
  pkg.removed:
    - name: python-crypto
    - require_in:
      - pip: pycrypto
