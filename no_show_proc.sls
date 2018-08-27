don't show proc output:
  file.append:
    - names:
      - /etc/environment
      - /etc/profile
    - text: 'export NO_SHOW_PROC=True'
