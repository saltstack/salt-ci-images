include:
  - windows.repo

vcredist:
  pkg.installed:
    - name: ms-vcpp-2013-redist_x64
    - require:
      - win-pkg-refresh
