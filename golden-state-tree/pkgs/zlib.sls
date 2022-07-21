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
{%- else %}
      - zlib
      - zlib-devel
{%- endif %}
