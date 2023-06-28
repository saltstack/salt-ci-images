jq:
  chocolatey.installed:
    - name: jq
    - require:
      - chocolatey-to-choco
