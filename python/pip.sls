{%- set distro = salt['grains.get']('oscodename', '')  %}
{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}
{%- set os = salt['grains.get']('os', '') %}

{%- if os_family == 'RedHat' and os_major_release == 6 %}
  {%- set on_redhat_6 = True %}
{%- else %}
  {%- set on_redhat_6 = False %}
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

{%- set force_reinstall = '' %}

{%- if pillar.get('py3', False) %}
  {%- set python = 'python3' %}
  {%- set pip = 'pip3' %}
  {%- if os == 'Fedora' %}
    {%- set force_reinstall = '--force-reinstall' %}
  {%- endif %}
{%- else %}
  {%- set pip = 'pip2' %}
  {%- if on_arch %}
    {%- set python = 'python2' %}
  {%- elif on_redhat_6 %}
    {%- set python = 'python2.7' %}
  {%- else %}
    {%- set python = 'python2' %}
  {%- endif %}
{%- endif %}


include:
  - curl
{%- if pillar.get('py3', False) %}
  - python3
{%- else %}
  {%- if on_arch %}
  - python27
  {%- endif %}
{%- endif %}

  {%- if on_debian_7 %}
  - python.headers
  {%- endif %}

{%- set get_pip = '{0} get-pip.py {1}'.format(python, force_reinstall) %}

pip-install:
  cmd.run:
    # -c <() because of https://github.com/pypa/get-pip/issues/37
    - name: curl -L 'https://bootstrap.pypa.io/get-pip.py' -o get-pip.py && {{ get_pip }} -c <(echo 'pip<=9.0.1')
    - cwd: /
    - reload_modules: True
    {%- if os != 'Fedora' %}
    - onlyif: '[ "$(which {{ pip }} 2>/dev/null)" = "" ]'
    {%- endif %}
    - require:
      - pkg: curl
    {%- if pillar.get('py3', False) %}
      - pkg: install_python3
      - cmd: pip2-install
    {%- else %}
      {%- if on_debian_7 %}
      - pkg: python-dev
      {%- endif %}
    {%- endif %}

upgrade-installed-pip:
  pip.installed:
    - name: pip <=9.0.1
    - upgrade: True
    - bin_env: {{ salt.config.get('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    - require:
      - cmd: pip-install

{%- if pillar.get('py3', False) %}
pip2-install:
  cmd.run:
    # -c <() because of https://github.com/pypa/get-pip/issues/37
    - name: curl -L 'https://bootstrap.pypa.io/get-pip.py' -o get-pip.py && python2 get-pip.py -c <(echo 'pip<=9.0.1')
    - cwd: /
    - reload_modules: True
    {%- if os != 'Fedora' %}
    - onlyif: '[ "$(which pip2 2>/dev/null)" = "" ]'
    {%- endif %}
    - require:
      - pkg: curl
    {%- if on_debian_7 %}
    - pkg: python-dev
    {%- endif %}

upgrade-installed-pip2:
  pip2.installed:
    - name: pip <=9.0.1
    - upgrade: True
    - bin_env: {{salt.config.get('virtualenv_path', '')}}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    - require:
      - cmd: pip2-install
{%- endif %}
