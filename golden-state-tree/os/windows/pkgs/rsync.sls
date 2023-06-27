rsync:
  chocolatey.installed:
    - name: rsync
    - require:
      - pkgs.choco_symlink
