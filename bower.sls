{% if grains['os'] == 'Ubuntu' %}
nodejs-legacy:
    pkg.installed
{% endif %}

bower:
  npm.installed:
    - require:
      - pkg: npm
      {# we expect OSX to have git available from the system, not the package manager (brew) #}
      {% if grains['os'] != 'MacOS' %}
      - pkg: git
      {% endif %}
      {% if grains['os'] == 'Ubuntu' %}
      - pkg: nodejs-legacy
      {% endif %}
