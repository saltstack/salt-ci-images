{%- set distro = salt['grains.get']('oscodename', '')  %}
{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}
{%- set os = salt['grains.get']('os', '') %}
{%- set get_pip_dir = salt.temp.dir(prefix='get-pip-') %}
{%- set get_pip_path = (get_pip_dir | path_join('get-pip.py')).replace('\\', '\\\\') %}

{%- if os_family == 'RedHat' and os_major_release == 6 %}
  {%- set on_redhat_6 = True %}
{%- else %}
  {%- set on_redhat_6 = False %}
{%- endif %}

{%- if os_family == 'RedHat' and os_major_release == 7 %}
  {%- set on_redhat_7 = True %}
{%- else %}
  {%- set on_redhat_7 = False %}
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

{%- if os_family == 'Windows' %}
  {%- set on_windows=True %}
{%- else %}
  {%- set on_windows=False %}
{%- endif %}

{%- if os == 'Fedora' %}
  {%- set force_reinstall = '--force-reinstall' %}
{%- else %}
  {%- set force_reinstall = '' %}
{%- endif %}

{%- set pip2 = 'pip2' %}
{%- set pip3 = 'pip3' %}

{%- if on_windows %}
  {#- TODO: Maybe run this by powershell `py.exe -3 -c "import sys; print(sys.executable)"` #}
  {%- set python2 = 'c:\\\\Python27\\\\python.exe' %}
  {%- set python3 = 'c:\\\\Python35\\\\python.exe' %}
{%- else %}
  {%- if on_redhat_6 %}
    {%- set python2 = 'python2.7' %}
  {%- else %}
    {%- set python2 = 'python2' %}
  {%- endif %}
  {%- if on_redhat_7 %}
    {%- set python3 = 'python3.4' %}
  {%- else %}
    {%- set python3 = 'python3' %}
  {%- endif %}
{%- endif %}


{%- if (not on_redhat_6 and not on_ubuntu_14 and not on_windows) or (on_windows and pillar.get('py3', False)) %}
  {%- set install_pip3 = True %}
{%- else %}
  {%- set install_pip3 = False %}
{%- endif %}

{%- if not on_windows or (on_windows and pillar.get('py3', False) == False) %}
  {%- set install_pip2 = True %}
{%- else %}
  {%- set install_pip2 = False %}
{%- endif %}

include:
{%- if pillar.get('py3', False) %}
  {%- if not on_redhat_6 and not on_ubuntu_14 %}
  - python3
  {%- endif %}
{%- else %}
  {%- if on_arch or on_windows %}
  - python27
  {%- endif %}
{%- endif %}
{%- if on_debian_7 %}
  - python.headers
{%- endif %}
  {%- if install_pip3 and grains['os'] == 'Ubuntu' and os_major_release >= 18 %}
  - python.distutils
  {%- endif %}
  - noop-placeholder {#- Make sure there's at least an entry in this 'include' statement #}

{%- set get_pip2 = '{} {} {}'.format(python2, get_pip_path, force_reinstall) %}
{%- set get_pip3 = '{} {} {}'.format(python3, get_pip_path, force_reinstall) %}

pip-install:
  cmd.run:
    - name: 'echo "Place holder for pip2 and pip3 installs"'
    - require:
      {%- if install_pip2 %}
      - cmd: pip2-install
      {%- endif %}
      {%- if install_pip3 %}
      - cmd: pip3-install
      {%- endif %}

download-get-pip:
  file.managed:
    - name: {{ get_pip_path }}
    - source: https://github.com/pypa/get-pip/raw/b3d0f6c0faa8e02322efb00715f8460965eb5d5f/get-pip.py
    - skip_verify: true

{%- if install_pip3 %}
pip3-install:
  cmd.run:
    {%- if on_windows %}
    - name: '{{ get_pip3 }} "pip<=9.0.1"'
    {%- else %}
    - name: {{ get_pip3 }} 'pip<=9.0.1'
    {%- endif %}
    - cwd: /
    - reload_modules: True
    - onlyif:
      {%- if not on_windows %}
      - '[ "$(which {{ python3 }} 2>/dev/null)" != "" ]'
        {%- if os != 'Fedora' %}
      - '[ "$(which {{ pip3 }} 2>/dev/null)" = "" ]'
        {%- endif %}
      {%- endif %}
    - require:
      - download-get-pip
    {%- if install_pip3 and grains['os'] == 'Ubuntu' and os_major_release >= 18 %}
      - python3-distutils
    {%- endif %}
    {%- if pillar.get('py3', False) %}
      - pkg: python3
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
      {%- if on_windows %}
      - 'if (py.exe -3 -c "import sys; print(sys.executable)") { exit 0 } else { exit 1 }'
      - 'if (get-command pip3) { exit 0 } else { exit 1 }'
      {%- else %}
      - '[ "$(which {{ python3 }} 2>/dev/null)" != "" ]'
      - '[ "$(which {{ pip3 }} 2>/dev/null)" != "" ]'
      {%- endif %}
    - require:
      - cmd: pip3-install
{%- endif %}

{%- if install_pip2 %}
pip2-install:
  cmd.run:
    {%- if on_windows %}
    - name: '{{ get_pip2 }} "pip<=9.0.1"'
    {%- else %}
    - name: {{ get_pip2 }} 'pip<=9.0.1'
    {%- endif %}
    - cwd: /
    - reload_modules: True
    - onlyif:
      {%- if not on_windows %}
      - '[ "$(which {{ python2 }} 2>/dev/null)" != "" ]'
        {%- if os != 'Fedora' %}
      - '[ "$(which {{ pip2 }} 2>/dev/null)" = "" ]'
        {%- endif %}
      {%- endif %}
    - require:
      - download-get-pip
    {%- if on_windows and not pillar.get('py3', False) %}
      - pkg: python2
    {%- elif on_debian_7 %}
      - pkg: python-dev
    {%- endif %}

upgrade-installed-pip2:
  pip2.installed:
    - name: pip <=9.0.1
    - upgrade: True
    - onlyif:
      {%- if on_windows %}
      - 'py.exe -2 -c "import sys; print(sys.executable)"'
      - 'if (get-command pip3) { exit 0 } else { exit 1 }'
      {%- else %}
      - '[ "$(which {{ python2 }} 2>/dev/null)" != "" ]'
      - '[ "$(which {{ pip2 }} 2>/dev/null)" != "" ]'
    {%- endif %}
    - require:
      - cmd: pip2-install
{%- endif %}
