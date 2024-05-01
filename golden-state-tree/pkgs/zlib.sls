zlib:
  pkg.latest:
    - pkgs:
{%- if grains['os_family'] == "Arch" %}
      - zlib
{%- elif grains['os_family'] == "Debian" %}
      - zlib1g
      - zlib1g-dev
{%- elif grains['os_family'] == "Suse" %}
      - libz1
      - zlib-devel
{%- elif grains['os'] == "Fedora" %}
      - zlib-ng-compat
      - zlib-ng-compat-devel
{%- else %}
      - zlib
      - zlib-devel
{%- endif %}
