{% if grains['kernel'] == 'Linux' %}

bower:
  npm.installed:
    - require:
      - pkg: npm
      - pkg: git

{% endif %}
