os_update:
  cmd.run:
    {%- if grains['os'] == 'Arch' %}
    - name: pacman -Syu
    {%- elif grains['os_family'] == 'Suse' %}
    - name: zypper update
    {%- endif %}
    - cwd: /
