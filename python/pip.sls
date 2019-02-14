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

{% if os in ('Windows') %}
  {% set install_method = 'pip' %}
{% else %}
  {% set install_method = 'pkg' %}
{% endif %}

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
{%- if os_family != 'Windows' %}
  - python3
{%- endif %}
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
    - name: curl -L 'https://github.com/pypa/get-pip/raw/b3d0f6c0faa8e02322efb00715f8460965eb5d5f/get-pip.py' -o get-pip.py && {{ get_pip }} 'pip<=9.0.1'
    - cwd: /
    - reload_modules: True
    {%- if os != 'Fedora' %}
    - onlyif: '[ "$(which {{ pip }} 2>/dev/null)" = "" ]'
    {%- endif %}
    - require:
      - {{ install_method }}: curl
    {%- if pillar.get('py3', False) %}
    {%- if os_family != 'Windows' %}
      - pkg: python3
      - cmd: pip2-install
    {%- endif %}
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
    - require:
      - cmd: pip-install

{%- if pillar.get('py3', False) and os != 'Windows' %}
pip2-install:
  cmd.run:
    - name: curl -L 'https://github.com/pypa/get-pip/raw/b3d0f6c0faa8e02322efb00715f8460965eb5d5f/get-pip.py' -o get-pip.py && python2 get-pip.py 'pip<=9.0.1'
    - cwd: /
    - reload_modules: True
    {%- if os != 'Fedora' %}
    - onlyif: '[ "$(which pip2 2>/dev/null)" = "" ]'
    {%- endif %}
    - require:
      - {{ install_method }}: curl
    {%- if on_debian_7 %}
    - pkg: python-dev
    {%- endif %}

upgrade-installed-pip2:
  pip2.installed:
    - name: pip <=9.0.1
    - upgrade: True
    - bin_env: {{salt.config.get('virtualenv_path', '')}}
    - require:
      - cmd: pip2-install
{%- endif %}
