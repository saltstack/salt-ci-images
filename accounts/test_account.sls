{% set test_username = pillar.get('test_username', 'testuser') %}
sudo:
  pkg.installed

{{ test_username }}:
  user.present:
    - shell: /bin/bash
    - home: /home/{{ test_username }}
    - createhome: True
    - empty_password: True
    - groups:
      - root

/etc/sudoers.d/{{ test_username }}:
  file.managed:
    - source: salt://accounts/files/sudoers_test_account
    - user: root
    - group: root
    - mode: 440
    - template: jinja
    - context:
      test_username: {{ test_username }}
    - require:
      - pkg: sudo
      - user: {{ test_username }}

tests_pubkey:
  ssh_auth:
    - present
    - user: {{ test_username }}
    - names:
      - {{ pillar.get('tests_pubkey') }}
