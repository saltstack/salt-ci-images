rsync:
  chocolatey.installed:
    - name: rsync
    - require:
      - chocolatey-to-choco
