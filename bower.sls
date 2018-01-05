{% if grains['os'] == 'Ubuntu' %}
nodejs-legacy:
    pkg.installed:
      - aggregate: True
{% endif %}


{# for MacOS we want to install node, npm, and bower at the end for issue #41770, so skipping install here. #}
{% if grains['os'] != 'MacOS' %}
bower:
  npm.installed:
    - require:
      - pkg: npm
{% endif %}
      {# we expect OSX to have git available from the system, not the package manager (brew) #}
      {% if grains['os'] != 'MacOS' %}
      - pkg: git
      {% endif %}
      {% if grains['os'] == 'Ubuntu' %}
      - pkg: nodejs-legacy
      {% endif %}
