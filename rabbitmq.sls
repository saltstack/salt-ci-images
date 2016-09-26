rabbitmq server:
  pkg.latest:
    - pkgs:
      - rabbitmq-server

  service.running:
    - name: rabbitmq-server
    - enable: True

rabbitmq remove guest:
  rabbitmq_user.absent:
    - name: guest

rabbitmq create nova:
  rabbitmq_user.present:
    - name: nova
    - password: novapass
    - perms:
      - '/':
        - '.*'
        - '.*'
        - '.*'
