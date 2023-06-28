rust:
  chocolatey.installed:
    - name: rust
    - require:
      - pkgs.chocolatey-to-choco
