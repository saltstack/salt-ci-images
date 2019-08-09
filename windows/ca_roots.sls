ensure_target:
  file.directory:
    - name: c:\salt\srv\salt
    - makedirs: True

download_ca_roots_from_windows_update:
  cmd.run:
    - name: certutil -generateSSTFromWU c:\salt\srv\salt\roots.sst
    - require:
      - ensure_target

update_ca_roots_store:
  cmd.run:
    - name: (Get-ChildItem -Path c:\salt\srv\salt\roots.sst) | Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root | Out-Null; Out-Null; Write-Output "Import successful"
    - shell: powershell
    - require:
      - download_ca_roots_from_windows_update
