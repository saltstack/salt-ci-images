{%- if grains['os'] == 'CentOS Stream' and grains['osmajorrelease'] >= 9 %}
centos-crb-repo:
  pkgrepo.managed:
    - humanname: CentOS Stream $releasever - CRB
    - mirrorlist: https://mirrors.centos.org/metalink?repo=centos-crb-$stream&arch=$basearch&protocol=https,http
    - gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
    - gpgcheck: 1
    - enabled: 1
{%- elif grains['os'] == 'AlmaLinux' and grains['osmajorrelease'] >= 9 %}
centos-crb-repo:
  pkgrepo.managed:
    - humanname: AlmaLinux $releasever - CRB
    - mirrorlist: https://mirrors.almalinux.org/mirrorlist/$releasever/crb
    - gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-9
    - gpgcheck: 1
    - enabled: 1
{%- elif grains['os'] == 'Rocky' and grains['osmajorrelease'] >= 9 %}
rocky-crb-repo:
  pkgrepo.managed:
    - humanname: Rocky $releasever - CRB
    - name: crb
    - gpgcheck: 1
    - enabled: 1
{%- endif %}

swig:
  pkg.installed
