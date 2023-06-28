jq:
  chocolatey.installed:
    - name: jq
    - require:
      - sls: pkgs.choco_symlink
