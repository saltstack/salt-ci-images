install_rsync_deps:
  pkg.installed:
    - pkgs:
      - 7zip-zstd
      - git: '>=2.41.0.2'

install_rsync-git:
  pkg.installed:
    - name: rsync-git
    - require:
        - pkg: install_rsync_deps
