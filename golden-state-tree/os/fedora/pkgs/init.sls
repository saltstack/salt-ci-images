{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}

include:
  - pkgs.cron
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
  - pkgs.nginx
  - pkgs.openldap
  - pkgs.openssl
  - pkgs.openssl-dev
  - pkgs.patch
  - pkgs.python3-pip
  - pkgs.rng-tools
  - pkgs.rpmdevtools
  - pkgs.rsync
  - pkgs.sed
  - pkgs.swig
  - pkgs.tar
  - pkgs.zlib
  {%- if os_major_release != 38 %}
  {#- There's no vault packages for Fedora 38 yet as it's the unstable version of Fedora #}
  - pkgs.vault
  {%- endif %}
  - pkgs.jq
  - pkgs.xz
  - pkgs.tree
  - pkgs.cargo
  - pkgs.pyenv-python {#-
  - pkgs.awscli
  - pkgs.amazon-cloudwatch-agent #}

  {#- OS Specific packages install #}
  - .g++
  - .python3
