include:
  - .package

keystone config:
  file.managed:
    - name: /etc/keystone/keystone.conf
    - makedirs: True
    - contents: |
        [DEFAULT]
        admin_token = administrator
        [database]
        connection = sqlite:////var/lib/keystone/keystone.sqlite
        [token]
        provider = fernet
