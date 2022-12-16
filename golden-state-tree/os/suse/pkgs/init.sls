include:
  - pkgs.bower
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
  - pkgs.man
  - pkgs.npm
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
  - pkgs.jq
  - pkgs.xz {#-
  - pkgs.awscli
  - pkgs.amazon-cloudwatch-agent #}
  {#- OS Specific packages install #}
  - .python-xml   {#- Yes! openSuse ships xml as separate package #}
  {%- if not grains['osrelease'].startswith('15') %}
  - .python-zypp
  {%- endif %}
  - .cleanup
