{%- set git_binary = 'git' | which %}
git-exists-in-path:
  win_path.exists:
    - name: 'C:\Program Files\Git\cmd'

git-exists-in-path-unix:
  win_path.exists:
    - name: 'C:\Program Files\Git\usr\bin'

git-windeps:
  {%- if not git_binary %}
  pkg.installed:
    - name: git
    # TODO: When changing the version here, be sure to also change the version
    # TODO: in the powershell script so they don't compete with each other:
    # TODO: ./os-images/AWS/windows/scripts/Install-Git.ps1
    - version: 2.41.0.3
    - refresh_modules: True
    - extra_install_flags: "/GitAndUnixToolsOnPath"
    - require:
      - git-exists-in-path
      - git-exists-in-path-unix
  {%- else %}
  test.show_notification:
    - text: "Git is already installed"
  {%- endif %}
