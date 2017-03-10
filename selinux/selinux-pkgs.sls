selinux_pkgs:
  pkg.installed:
    - aggregate: True
    - pkgs:
      - policycoreutils
      - policycoreutils-python
