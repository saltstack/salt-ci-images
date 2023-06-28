rsync:
  chocolatey.installed:
    - name: rsync
    - require:
      - sls: pkgs.choco_symlink
