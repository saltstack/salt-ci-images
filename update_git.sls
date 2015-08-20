# Updates git on centos6

rpm-forge:
  cmd.run:
    - name: "rpm -i 'http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm'"

rpm-key:
  cmd.run: 
    - name: "rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt"
    - require: 
      - cmd: rpm-forge

/etc/yum.repos.d/rpmforge.repo:
  file.managed:
    - source: rpmforge.repo
    - user: root
    - group: root
    - mode: 644

git:
  pkg.latest:
    - name: git
    - require: 
      - cmd: rpm-key
