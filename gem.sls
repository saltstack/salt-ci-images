{% set debian = True if grains['os'] == 'Debian' else False %}

{% if debian %}
include:
  - openssl
{% endif %}

install_ruby:
  pkg.installed:
    - name: ruby
    {% if debian %}
    - require:
      - pkg: openssl
    {% endif %}

