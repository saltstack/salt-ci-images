ssh_config_arcfour128:
  cmd.run:
    - name: sed -i 's/arcfour128,//' /etc/ssh/ssh_config

ssh_config_arcfour256:
  cmd.run:
    - name: sed -i 's/arcfour256,//' /etc/ssh/ssh_config
