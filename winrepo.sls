{% if grains['os_family'] == 'Windows' %}
include:
   - python.dulwich

download-git-repos:
   module.run:
     - name: winrepo_bootstrap.download_git_repos
     - require:
       - dulwich

generate-pkg-repos:
   module.run:
     - name: winrepo.genrepo
     - require:
       - download-git-repos

win-pkg-refresh:
   module.run:
     - name: pkg.refresh_db
     - require:
       - generate-pkg-repos
{% endif %}
