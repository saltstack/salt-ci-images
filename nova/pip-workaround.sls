{#- need to use this workaround due to a psutils version error as documented here:
https://github.com/saltstack/salt-jenkins/pull/270#}

python-psutils:
  pip.installed:
    - name: psutil==2.2.1
