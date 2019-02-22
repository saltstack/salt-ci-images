os_update:
  cmd.run:
    {%- if grains['os'] == 'Arch' %}
    - name: pacman -Syu
    {%- elif grains['os'] == 'openSUSE' %}
    - name: zypper update
    {%- endif %}
    - cwd: /
