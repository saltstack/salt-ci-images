include:
  - .package

keystone config:
  file.managed:
    - name: /etc/keystone/keystone.conf
    - makedirs: True
    - template: jinja
    - source: salt://keystone/files/keystone.conf.jinja

  grains.present:
    - name: keystone.endpoint
    - value: http://127.0.0.1:35357/v2.0
