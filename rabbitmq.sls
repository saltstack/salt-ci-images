rabbitmq server:
  pkg.latest:
    - pkgs:
      - rabbitmq-server
    - force_yes: True

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
