{%- if grains['os'] == 'Ubuntu' %}
  {%- set ssh_service = 'ssh' %}
{%- elif grains['os'] == 'MacOS' %}
  {%- set ssh_service = 'com.openssh.sshd' %}
{%- else %}
  {%- set ssh_service = 'sshd' %}
{%- endif %}

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

{{ ssh_service }}:
  service.running:
    - watch:
      - file: append_permit_root_login_yes
      - file: commend_out_permit_root_login_no
      - file: debug_sshd_logging_append
      - file: debug_sshd_logging_replace
