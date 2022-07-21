include:
  - os
  - python-pkgs

provision-system:
  test.show_notification:
    - text: "System Provision Complete"
    - require:
      - provision-system-packages
      - provision-python-packages
