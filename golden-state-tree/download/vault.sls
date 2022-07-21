install-vault-binary:

  pkg.latest:
    - name: unzip

  archive.extracted:
    - name: /usr/local/bin/
    - source: https://releases.hashicorp.com/vault/0.9.6/vault_0.9.6_linux_amd64.zip
    - source_hash: https://releases.hashicorp.com/vault/0.9.6/vault_0.9.6_SHA256SUMS
    - archive_format: zip
    - if_missing: /usr/local/bin/vault
    - source_hash_update: True
    - enforce_toplevel: False
