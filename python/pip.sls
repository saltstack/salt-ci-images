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

{%- if os_family == 'Ubuntu' and os_major_release == 14 %}
  {%- set on_ubuntu_14 = True %}
{%- else %}
  {%- set on_ubuntu_14 = False %}
{%- endif %}

{% if os in ('Windows',) %}
  {% set install_method = 'pip' %}
{% else %}
  {% set install_method = 'pkg' %}
{% endif %}

{%- if os == 'Fedora' %}
  {%- set force_reinstall = '--force-reinstall' %}
{%- else %}
  {%- set force_reinstall = '' %}
{% endif %}

{%- set pip2 = 'pip2' %}
{%- set pip3 = 'pip3' %}
{%- if on_redhat_6 %}
  {%- set python2 = 'python2.7' %}
{%- else %}
  {%- set python2 = 'python2' %}
{%- endif %}
{%- set python3 = 'python3' %}

include:
  - curl
{%- if pillar.get('py3', False) %}
  {%- if os_family != 'Windows' and not on_redhat_6 and not on_ubuntu_14 %}
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

{%- set get_pip2 = '{0} get-pip.py {1}'.format(python2, force_reinstall) %}
{%- set get_pip3 = '{0} get-pip.py {1}'.format(python3, force_reinstall) %}

pip-install:
  cmd.run:
    - name: 'echo "Place holder for pip2 and pip3 installs"'
    - require:
      - cmd: pip2-install
      {%- if not on_redhat_6 and not on_ubuntu_14 %}
      - cmd: pip3-install
      {%- endif %}

{%- if not on_redhat_6 and not on_ubuntu_14 %}
pip3-install:
  cmd.run:
    - name: curl -L 'https://github.com/pypa/get-pip/raw/b3d0f6c0faa8e02322efb00715f8460965eb5d5f/get-pip.py' -o get-pip.py && {{ get_pip3 }} 'pip<=9.0.1'
    - cwd: /
    - reload_modules: True
    - onlyif:
      - '[ "$(which {{ python3 }} 2>/dev/null)" != "" ]'
    {%- if os != 'Fedora' %}
      - '[ "$(which {{ pip3 }} 2>/dev/null)" = "" ]'
    {%- endif %}
    - require:
      - pkg: curl
    {%- if pillar.get('py3', False) %}
      {%- if os_family != 'Windows' %}
      - pkg: python3
      {%- endif %}
    {%- else %}
      {%- if on_debian_7 %}
      - pkg: python-dev
      {%- endif %}
    {%- endif %}

upgrade-installed-pip3:
  pip3.installed:
    - name: pip <=9.0.1
    - upgrade: True
    - onlyif:
      - '[ "$(which {{ python3 }} 2>/dev/null)" != "" ]'
      - '[ "$(which {{ pip3 }} 2>/dev/null)" != "" ]'
    - require:
      - cmd: pip3-install
{%- endif %}

pip2-install:
  cmd.run:
    - name: curl -L 'https://github.com/pypa/get-pip/raw/b3d0f6c0faa8e02322efb00715f8460965eb5d5f/get-pip.py' -o get-pip.py && {{ get_pip2 }} 'pip<=9.0.1'
    - cwd: /
    - reload_modules: True
    - onlyif:
      - '[ "$(which {{ python2 }} 2>/dev/null)" != "" ]'
    {%- if os != 'Fedora' %}
      - '[ "$(which {{ pip2 }} 2>/dev/null)" = "" ]'
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
    - onlyif:
      - '[ "$(which {{ python2 }} 2>/dev/null)" != "" ]'
      - '[ "$(which {{ pip2 }} 2>/dev/null)" != "" ]'
    - require:
      - cmd: pip2-install
