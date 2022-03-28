include:
  - curl

install-pytenv:
  cmd.run:
    - name: curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
    - require:
      - curl

append-pyenv-bin-to-path:
  file.append:
    - name: /root/.bash_profile
    - text: 'export PATH="$HOME/.pyenv/bin:$PATH"'
    - unless: 'echo $PATH | grep -q /root/.pyenv/bin'
    - require:
      - install-pyenv
