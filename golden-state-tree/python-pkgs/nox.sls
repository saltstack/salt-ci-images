{%- if grains['os'] == 'VMware Photon OS' %}
  {#-
    The latest version of nox pulls in packaging, which is already installed
    on PhotonOS AMIs. If we try to uninstall that the following would also
    be uninstalled:
      python3-requests
      python3-pyOpenSSL
      python3-packaging
      python3-cryptography
      minimal
      cloud-init

    The last one seems important, so we'll just use an older version of nox
  #}
  {%- set nox_version = '2020.12.31' %}
{%- else %}
  {%- set nox_version = '2022.1.7' %}
{%- endif %}

{%- if grains['os_family'] == 'Windows' %}
  {%- set on_windows=True %}
{%- else %}
  {%- set on_windows=False %}
{%- endif %}

{%- if grains['os_family'] == 'FreeBSD' %}
  {%- set on_freebsd=True %}
{%- else %}
  {%- set on_freebsd=False %}
{%- endif %}

{%- if on_windows %}
  {%- set pip = 'py -3 -m pip' %}
{%- else %}
  {%- if on_freebsd %}
    {%- set pip = 'pip-3.9' %}
  {%- else %}
    {%- set pip = 'pip3' %}
  {%- endif %}
{%- endif %}

{%- set which_nox = 'nox' | which %}

{%- if not which_nox %}
nox:
  cmd.run:
  {%- if not on_windows %}
    {%- if (grains['os'] == 'Debian' and grains['osmajorrelease'] >= 12) or (grains['os'] == 'Ubuntu' and grains['osmajorrelease'] >= 23) or grains['os'] == 'Arch' %}
    - name: "{{ pip }} install 'nox=={{ nox_version }}' --break-system-packages"
    {%- else %}
    - name: "{{ pip }} install 'nox=={{ nox_version }}'"
    {%- endif %}
  {%- else %}
    - name: {{ pip }} install nox=={{ nox_version }}
  {%- endif %}

  {%- if not on_windows %}
symlink-nox:
  file.symlink:
    - name: /usr/bin/nox
    - target: /usr/local/bin/nox
    - onlyif: '[ -f /usr/local/bin/nox ]'
    - require:
      - nox
  {%- endif %}

nox-version:
  cmd.run:
  {%- if not on_windows %}
    - name: 'nox --version'
  {%- else %}
    - name: 'py -3 -m nox --version'
  {%- endif %}
    - require:
      - nox
  {%- if grains['os'] == 'MacOS' %}
    - runas: vagrant
  {%- endif %}
{%- endif %}
