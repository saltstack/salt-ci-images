git-exists-in-path:
  win_path.exists:
    - name: 'C:\Program Files\Git\cmd'

git-windeps:
  pkg.installed:
    - name: git
    - refresh_modules: True
    - require:
      - win-pkg-refresh
      - git-exists-in-path
