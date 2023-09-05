download-and-extract-libsodium:
  archive.extracted:
    - name: /root/
    - source: https://salt-onedir-golden-images-provision.s3.us-west-2.amazonaws.com/libsodium-1.0.18.tar.gz
    - source_hash: sha256=6f504490b342a4f8a4c4a02fc9b866cbef8622d5df4e5452b46be121e46636c1
    - keep_source: False

configure-libsodium:
  cmd.run:
    - name: './configure'
    - cwd: /root/libsodium-1.0.18

make-and-check-libsodium:
  cmd.run:
    - name: make && make check
    - cwd: /root/libsodium-1.0.18

make-install-libsodium:
  cmd.run:
    - name: make install
    - cwd: /root/libsodium-1.0.18

add-libsodium-to-ldconf:
  cmd.run:
    - name: echo /usr/local/lib | sudo tee /etc/ld.so.conf.d/local.conf

ldconfig-libsodium:
  cmd.run:
    - name: ldconfig && ldconfig -p | grep libsodium
