rust:
  chocolatey.installed:
    - name: rust
    - require:
      - pkgs.choco_symlink
