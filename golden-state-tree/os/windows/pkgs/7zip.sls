7zip:
  pkg.installed

7zip-exists-in-path:
  win_path.exists:
    - name: 'C:\Program Files\7-Zip'
