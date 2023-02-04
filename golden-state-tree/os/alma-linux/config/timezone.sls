include:
  - pkgs.tzdata

symlink-timezone-file:
  file.symlink:
    - name: /etc/localtime
    - target: /usr/share/zoneinfo/UTC
    - force: true
    - require:
      - tzdata
