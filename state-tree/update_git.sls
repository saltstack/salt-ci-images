# Updates git on centos6

rpm-forge:
  cmd.run:
    - name: "rpm -i 'http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm'"

rpm-key:
  cmd.run:
    - name: "rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt"
    - require:
      - cmd: rpm-forge

rpmforge_repo:
  file.managed:
    - name: /etc/yum.repos.d/rpmforge.repo
    - source: salt://rpmforge.repo
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: rpm-key

update_git:
  pkg.latest:
    - name: git
    - require:
      - file: rpmforge_repo
