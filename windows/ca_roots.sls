download_ca_roots_from_windows_update:
  cmd.run:
    - name: certutil -generateSSTFromWU %temp%\roots.sst

update_ca_roots_store:
  cmd.run:
    - name: (Get-ChildItem -Path $env:Temp\roots.sst) | Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root
    - shell: powershell
    - require:
      - download_ca_roots_from_windows_update
