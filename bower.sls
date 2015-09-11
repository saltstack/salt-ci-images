{% if grains['os'] == 'Ubuntu' %}
nodejs-legacy:
    pkg.installed
{% endif %}

bower:
  npm.installed:
    - require:
      - pkg: npm
      - pkg: git
      {% if grains['os'] == 'Ubuntu' %}
      - pkg: nodejs-legacy
      {% endif %}
