include:
  - pkgs.curl
  - pkgs.dmidecode
  - pkgs.dnsutils
  - pkgs.docker
  - pkgs.gcc
  - pkgs.gpg
  - pkgs.ipset
  - pkgs.libcurl
  - pkgs.libffi
  - pkgs.libgit2
  - pkgs.libsodium
  - pkgs.libxml
  - pkgs.libxslt
  - pkgs.make
  - pkgs.man
  - pkgs.nginx
  - pkgs.openldap
  - pkgs.openssl
  - pkgs.openssl-dev
  - pkgs.patch
  - pkgs.python3
  - pkgs.python3-pip
  - pkgs.rng-tools
  - pkgs.rsync
  - pkgs.sed
  - pkgs.swig
  - pkgs.tar
  - pkgs.zlib
  - pkgs.vault
  - pkgs.jq
  - pkgs.xz
  - pkgs.tree
  - pkgs.cargo
  {%- if grains['osmajorrelease']|int < 11 %}
  - pkgs.pyenv-python
  {%- endif %} {#-
  - pkgs.awscli
  - pkgs.amazon-cloudwatch-agent #}

  {#- OS Specific packages install #}
  - .apt-utils
  - .libdpkg-perl
  - .timesync
