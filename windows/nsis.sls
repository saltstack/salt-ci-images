include:
  - windows.repo

nsis:
  pkg.installed:
    - aggregate: False
    - require:
      - win-pkg-refresh
