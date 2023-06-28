rsync:
  chocolatey.installed:
    - name: rsync
    - require:
      - pkgs.chocolatey-to-choco
