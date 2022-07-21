include:
  {%- if grains['os'] == 'AlmaLinux' %}
  - os.alma-linux
  {%- elif grains['os'] == 'Amazon' %}
  - os.amazon
  {%- elif grains['os_family'] == 'Arch' %}
  - os.arch
  {%- elif grains['os'] == 'CentOS' %}
  - os.centos
  {%- elif grains['os'] == 'CentOS Stream' %}
  - os.centos-stream
  {%- elif grains['os'] == 'Debian' %}
  - os.debian
  {%- elif grains['os'] == 'Fedora' %}
  - os.fedora
  {%- elif grains['os'] == 'FreeBSD' %}
  - os.freebsd
  {%- elif grains['os'] == 'MacOS' %}
  - os.macos
  {%- elif grains['os'] == 'VMware Photon OS' %}
  - os.photon
  {%- elif grains['os_family'] == 'Suse' %}
  - os.suse
  {%- elif grains['os'] == 'Ubuntu' %}
  - os.ubuntu
  {%- elif grains['os'] == 'Windows' %}
  - os.windows
  {%- endif %}


provision-system-packages:
  test.show_notification:
    - text: "System Packages Provision Complete"
