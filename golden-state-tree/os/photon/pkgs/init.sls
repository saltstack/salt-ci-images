include:
  - pkgs.cron
  - pkgs.bower
  - pkgs.curl
  - pkgs.dmidecode
  - pkgs.dnsutils
  - pkgs.docker
  - pkgs.gcc
  - pkgs.gpg
  - pkgs.libcurl
  - pkgs.libffi
  - pkgs.libsodium
  - pkgs.libxml
  - pkgs.libxslt
  - pkgs.man
  - pkgs.npm
  - pkgs.openldap
  - pkgs.openssl
  - pkgs.openssl-dev
  - pkgs.patch
  - pkgs.python3
  - pkgs.python3-pip
  {%- if grains['cpuarch'].lower() == 'x86_64' %}
  - pkgs.rng-tools
  {%- endif %}
  - pkgs.rsync
  - pkgs.sed
  - pkgs.swig
  - pkgs.tar
  - pkgs.zlib
  - pkgs.jq
  - pkgs.xz
  - pkgs.tree
  - pkgs.rust {#-
  - pkgs.awscli
  - pkgs.amazon-cloudwatch-agent #}
  - pkgs.samba
