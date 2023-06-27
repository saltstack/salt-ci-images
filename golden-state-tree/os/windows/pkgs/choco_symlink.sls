# Ensure there is a symlink from chocolatey.exe to choco.exe
chocolatey-to-choco:
  file.symlink:
    - name: 'C:\ProgramData\chocolatey\bin\chocolatey.exe'
    - target: 'C:\ProgramData\chocolatey\bin\choco.exe'
