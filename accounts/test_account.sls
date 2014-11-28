{#-
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
      - {{ pillar.get('test_pubkey') }}

-#}

tests_pubkey_root:
  ssh_auth:
    - present
    - user: root
    - names:
      - {{ pillar.get('test_pubkey') }}

debug_sshd_logging_replace:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: 'LogLevel (.*)'
    - repl: 'LogLevel DEBUG3'
    - onlyif: grep -Eq '^LogLevel (.*)$' /etc/ssh/sshd_config

debug_sshd_logging_append:
  file.append:
    - name: /etc/ssh/sshd_config
    - text: LogLevel DEBUG3
    - onlyif: grep -Eq '^#LogLevel (.*)$' /etc/ssh/sshd_config

commend_out_permit_root_login_no:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: 'PermitRootLogin no'
    - repl: '#PermitRootLogin no'
    - onlyif: grep -q '^PermitRootLogin no$' /etc/ssh/sshd_config

append_permit_root_login_yes:
  file.append:
    - name: /etc/ssh/sshd_config
    - text: PermitRootLogin yes
    - onlyif: grep -qv '^PermitRootLogin yes$' /etc/ssh/sshd_config

sshd:
  service.running:
    - watch:
      - file: append_permit_root_login_yes
      - file: commend_out_permit_root_login_no
      - file: debug_sshd_logging_append
      - file: debug_sshd_logging_replace
