user-sudo:
  file.line:
    - name: /etc/sudoers
    - content: '{{ pillar['username'] }} ALL=(ALL) NOPASSWD: ALL'
    - after: '#includedir /private/etc/sudoers.d'
    - mode: Ensure
