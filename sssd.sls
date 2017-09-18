sssd:
  service.dead:
    - onlyif: systemctl is-active sssd
