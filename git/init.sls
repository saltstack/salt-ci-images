{% if grains['os_family'] == 'Debian' %}
  {% set git = 'git-core' %}
{%- elif grains['os'] == 'Windows' %}
  {% set PROGRAM_FILES = "%ProgramFiles%" %}
{%- elif grains['os'] == 'Gentoo' %}
  {% set git = 'dev-vcs/git' %}
{% else %}
  {% set git = 'git' %}
{% endif %}

{%- if grains['os_family'] == 'RedHat' %}
include:
   - python.ca-certificates
{%- endif %}

git:
{% if grains['os_family'] == 'Windows' %}
  module.run:
    - name: winrepo_pkg.install
    - args:
      - git
    - kwargs:
        win_repo:
          git:
            2.16.2:
              full_name: Git version 2.16.2
            {% if grains['cpuarch'] == 'AMD64' %}
              installer: https://github.com/git-for-windows/git/releases/download/v2.16.2.windows.1/Git-2.16.2-64-bit.exe
            {% else %}
              installer: https://github.com/git-for-windows/git/releases/download/v2.16.2.windows.1/Git-2.16.2-32-bit.exe
            {% endif %}
              install_flags: /VERYSILENT /NORESTART /SP- /NOCANCEL
              uninstaller: {{ PROGRAM_FILES }}\Git\unins000.exe
              uninstall_flags: /VERYSILENT /NORESTART
              msiexec: False
              locale: en_US
              reboot: False
{% else %}
  pkg.installed:
    - name: {{ git }}
    - aggregate: True
    - refresh: True  # Ensure that pacman runs the first time with -Syu
    {%- if grains['os_family'] == 'RedHat' %}
    - require:
      - pkg: ca-certificates
    {%- endif %}
{% endif %}
