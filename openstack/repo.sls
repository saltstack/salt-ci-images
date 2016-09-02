{%- if grains['os_family'] == 'RedHat' %}
openstack repo:
  pkgrepo.managed:
    - name: openstack-mitaka
    - humanname: OpenStack Mitaka Repository
    - baseurl: http://mirror.centos.org/centos/7/cloud/$basearch/openstack-mitaka/
    - gpgcheck: 0
    - disabled: 0
{%- elif grains['os'] == 'Ubuntu' and grains['osrelease'] == '14.04' %}
openstack repo:
  pkgrepo.managed:
    - name: openstack-mitaka
    - humanname: OpenStack Mitaka Repository
    - name: deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/mitaka main
    - dist: trusty-updates/mitaka
    - file: /etc/apt/sources.list.d/openstack.list
    - keyid: 9F68104E
    - keyserver: keyserver.ubuntu.com
{%- endif %}
