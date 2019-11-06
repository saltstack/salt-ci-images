{%- if grains['os'] == 'Ubuntu' %}
nodejs-legacy:
    pkg.installed:
      - aggregate: True
{%- endif %}

{#- for MacOS we want to install node, npm, and bower at the end for issue #41770, so skipping install here. #}
{%- if grains['os'] != 'MacOS' %}

{#- osrelease is used here for legacy reasions.  Old jenkins used 2016.3.1 for ub14, which did not have osmajorrelease for ubuntu systems #}
{%- set ubuntu14 = grains.os == 'Ubuntu' and grains.osrelease|int == 14 %}
{%- set centos6 = grains.os == 'CentOS' and grains.osmajorrelease|int == 6 %}

  {%- if ubuntu14 or centos6 %}
  {#- workaround for https://github.com/npm/npm/issues/20191 #}
npm_ssl_config:
  cmd.run:
    - name: npm config set strict-ssl false
  {%- endif %}

bower:
  npm.installed:
    {%- if ubuntu14 or centos6 %}
    - registry: http://registry.npmjs.org/
    {%- endif %}
    - require:
      - pkg: npm
      {%- if grains['os'] == 'Ubuntu' %}
      - pkg: nodejs-legacy
      {%- endif %}
{%- endif %}
