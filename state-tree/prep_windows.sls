setup windows dep environment:
  cmd.run:
    - name: "{{salt.config.get('root_dir').replace('\\', '\\\\')}}\\testing\\pkg\\windows\\build_env_{{3 if pillar.get('py3') else 2}}.ps1 -Silent"
    - shell: powershell
    - reload_modules: true
    - timeout: 600
    - retry:
        attempts: 2
        until: True
