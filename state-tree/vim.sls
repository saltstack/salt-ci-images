{%- if grains['os'] == 'Windows' %}
# just 32-bit x86 installer available
# https://raw.githubusercontent.com/gpwen/vim-installer-mui2/wiki-files/gen/vim73_install_manual.txt
{%- if grains['cpuarch'] == 'AMD64' %}
    {%- set PROGRAM_FILES = "%ProgramFiles(x86)%" %}
{%- else %}
    {%- set PROGRAM_FILES = "%ProgramFiles%" %}
{%- endif %}
vim:
  module.run:
    - name: winrepo_pkg.install
    - args:
      - gvim
    - kwargs:
        win_repo:
          gvim:
            2.16.2:
              full_name:  'Vim 8.0.3'
              installer: 'http://netcologne.dl.sourceforge.net/project/cream/Vim/8.0.3/gvim-8-0-3.exe'
              install_flags: '/S /BATCH /CONSOLE'
              uninstaller: '{{ PROGRAM_FILES }}\Vim\vim80\uninstall.exe'
              uninstall_flags: '/S'
              msiexec: False
              locale: en_US
              reboot: False

'{{ PROGRAM_FILES }}\vim\vim80':
    win_path.exists

{%- endif %}
