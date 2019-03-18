include:
  - windows.repo

vcredist:
  pkg.installed:
    - name: ms-vcpp-2013-redist_x64
    - require:
      - win-pkg-refresh

#  module.run:
#    - name: winrepo_pkg.install
#    - args:
#       - ms-vcpp-2017-redist_x64
#    - kwargs:
#        win_repo:
#          ms-vcpp-2017-redist_x64:
#            '14.11.25325.0':
#              full_name: 'Microsoft Visual C++ 2017 Redistributable (x64) - 14.11.25325.0'
#              installer: 'https://aka.ms/vs/15/release/vc_redist.x64.exe'
#              install_flags: '/quiet /norestart'
#              uninstaller: 'https://aka.ms/vs/15/release/vc_redist.x64.exe'
#              uninstall_flags: '/uninstall /quiet /norestart'
#              msiexec: False
#              locale: en_US
#              reboot: False
