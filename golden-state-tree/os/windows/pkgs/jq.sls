jq:
  chocolatey.installed:
    - name: jq
    - require:
      - pkgs.chocolatey-to-choco
