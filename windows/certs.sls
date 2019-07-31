system-certs-update:
  cmd.run:
    - name: certutil -generateSSTFromWU roots.sst && powershell "(Get-ChildItem -Path .\roots.sst) | Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root"
