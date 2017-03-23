{%- set distro = salt['grains.get']('oscodename', '')  %}
{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', '') %}

{%- if os_family == 'RedHat' and os_major_release[0] == '5' %}
  {%- set on_redhat_5 = True %}
{%- else %}
  {%- set on_redhat_5 = False %}
{%- endif %}

{%- if os_family == 'Debian' and distro == 'wheezy' %}
  {%- set on_debian_7 = True %}
{%- else %}
  {%- set on_debian_7 = False %}
{%- endif %}

{%- if os_family == 'Arch' %}
  {%- set on_arch = True %}
{%- else %}
  {%- set on_arch = False %}
{%- endif %}

{%- if pillar.get('py3', False) %}
  {%- set python = 'python3' %}
  {%- set pip = 'pip3' %}
{%- else %}
  {%- set pip = 'pip2' %}
  {%- if on_arch %}
    {%- set python = 'python2' %}
  {%- elif on_redhat_5 %}
    {%- set python = 'python26' %}
  {%- else %}
    {%- set python = 'python' %}
  {%- endif %}
{%- endif %}


include:
  - curl
{%- if pillar.get('py3', False) %}
{%- if os_family != 'Windows' %}
  - python3
{%- endif %}
{%- else %}
  {%- if on_redhat_5 %}
  - python26
  {%- endif %}
  {%- if on_arch %}
  - python27
  {%- endif %}
{%- endif %}

  {%- if on_debian_7 %}
  - python.headers
  {%- endif %}

{%- set get_pip = '{0} get-pip.py'.format(python) %}

force-sync-all:
  module.run:
    - name: saltutil.sync_all

pip-install:
  cmd.run:
    - name: curl -L 'https://bootstrap.pypa.io/get-pip.py' -o get-pip.py && {{ get_pip }} -U pip
    - cwd: /
    - reload_modules: True
    - onlyif: '[ "$(which {{ pip }} 2>/dev/null)" = "" ]'
    - require:
    {%- if grains['os_family'] == 'Windows' %}
      - pip: curl
    {%- else %}
      - pkg: curl
    {%- endif %}
    {%- if pillar.get('py3', False) %}
    {%- if os_family != 'Windows' %}
      - pkg: install_python3
    {%- endif %}
    {%- else %}
      - cmd: pip2-install
      {%- if on_redhat_5 %}
      - pkg: python26
      {%- endif %}
      {%- if on_debian_7 %}
      - pkg: python-dev
      {%- endif %}
    {%- endif %}

upgrade-installed-pip:
  pip.installed:
    - name: pip
    - upgrade: True
    - require:
      - cmd: pip-install

{%- if pillar.get('py3', False) %}
{%- if os_family != 'Windows' %}
pip2-install:
  cmd.run:
    - name: curl -L 'https://bootstrap.pypa.io/get-pip.py' -o get-pip.py && python2 get-pip.py -U pip
    - cwd: /
    - reload_modules: True
    - onlyif: '[ "$(which pip2 2>/dev/null)" = "" ]'
    - require:
      - pkg: curl
    {%- if on_redhat_5 %}
    - pkg: python26
    {%- endif %}
    {%- if on_debian_7 %}
    - pkg: python-dev
    {%- endif %}

upgrade-installed-pip2:
  pip2.installed:
    - name: pip
    - upgrade: True
    - require:
      - cmd: pip2-install
{%- endif %}
{%- endif %}
