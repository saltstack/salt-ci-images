include:
  - selinux.selinux-pkgs

set_permissive:
    selinux.mode:
      - name: permissive
      - require:
        - pkg: selinux_pkgs
