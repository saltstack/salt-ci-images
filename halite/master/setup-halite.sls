include:
  - git
{%- if grains['os_family'] not in ('FreeBSD', 'Gentoo') %}
  - gcc
{%- endif %}
  - python.pip
{%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo') %}
{#- These distributions don't ship the develop headers separately #}
  - python.headers
{%- endif %}
  - curl
  - python.nose
  - python.paste
  - python.webtest

https://github.com/saltstack/halite.git:
  git.latest:
    - rev: master
    - target: /root/halite
    - require:
      - pkg: git

halite-pkg:
  pip.installed:
    - editable: '/root/halite'
    - require:
      - cmd: python-pip

install-nvm:
  cmd.run:
    - name: 'curl https://raw.github.com/creationix/nvm/master/install.sh | sh'
    - require:
      - pkg: curl

install-js-halite:
  cmd.script:
    - source: salt://halite/master/files/install_node_npm.sh
    - cwd: /root/halite

ui-tester:
  user.present:
    - groups:
      - sudo
    - password: {{ pillar.get('halite_password_hash', 'U1234567890') }}

write-override-file:
  file.managed:
    - source: salt://halite/master/files/override.conf
    - name: /root/halite/halite/test/functional/config/override.conf
    - user: root
    - group: root
    - template: jinja
