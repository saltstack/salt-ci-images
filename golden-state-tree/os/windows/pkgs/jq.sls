jq:
  chocolatey.installed:
    - name: jq
    - require:
      - pkgs.choco_symlink
