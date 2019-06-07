include:
  - windows.repo

openssl:
  module.run:
    - name: winrepo_pkg.install
    - args:
       - openssl
    - kwargs:
        win_repo:
          openssl:
            'openssl':
              full_name: 'Openssl'
              installer: 'https://slproweb.com/download/Win64OpenSSL-1_0_2s.exe'
              install_flags: '/silent'
              uninstaller: 'https://slproweb.com/download/Win64OpenSSL-1_0_2s.exe'
              uninstall_flags: ''
              msiexec: False
              locale: en_US
              reboot: False
