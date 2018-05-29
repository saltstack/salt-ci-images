{% if grains['os'] == 'Ubuntu' %}
nodejs-legacy:
    pkg.installed:
      - aggregate: True
{% endif %}

{% set ubuntu14 = grains.os == 'Ubuntu' and grains.osmajorrelease|int == 14 %}
{% set centos6 = grains.os == 'CentOS' and grains.osmajorrelease|int == 6 %}

{%- if ubuntu14 or centos6 %}
{# workaround for https://github.com/npm/npm/issues/20191 #}
npm_ssl_config:
  cmd.run:
    - name: npm config set strict-ssl false
{% endif %}

bower:
  npm.installed:
    {%- if ubuntu14 or centos6 %}
    - registry: http://registry.npmjs.org/
    {%- endif %}
    - require:
      - pkg: npm
      {# we expect OSX to have git available from the system, not the package manager (brew) #}
      {% if grains['os'] != 'MacOS' %}
      - pkg: git
      {% endif %}
      {% if grains['os'] == 'Ubuntu' %}
      - pkg: nodejs-legacy
      {% endif %}
