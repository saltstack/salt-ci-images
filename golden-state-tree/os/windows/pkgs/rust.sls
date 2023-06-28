rust:
  chocolatey.installed:
    - name: rust
    - require:
      - sls: pkgs.choco_symlink
