{%- set git_binary = 'git' | which %}
git-exists-in-path:
  win_path.exists:
    - name: 'C:\Program Files\Git\cmd'

git-windeps:
  {%- if not git_binary %}
  pkg.installed:
    - name: git
    - refresh_modules: True
    - require:
      - win-pkg-refresh
      - git-exists-in-path
  {%- else %}
  test.show_notification:
    - text: "Git is already installed"
  {%- endif %}
