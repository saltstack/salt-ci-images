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

{%- if os_family == 'RedHat' and os_major_release == 2018 %}
  {%- set on_amazonlinux_1 = True %}
{%- else %}
  {%- set on_amazonlinux_1 = False %}
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

{%- if grains['os'] == 'MacOS' %}
  {%- set on_macos = True %}
{%- else %}
  {%- set on_macos = False %}
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
  {%- if on_redhat_6 or on_amazonlinux_1 %}
    {%- set python2 = 'python2.7' %}
  {%- else %}
    {%- set python2 = 'python2' %}
  {%- endif %}
  {%- if on_amazonlinux_1 %}
    {%- set python3 = 'python3.6' %}
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

{%- set which_pip2 = pip2 | which %}
{%- set which_python2 = python2 | which %}
{%- set get_pip2 = '{} {} {}'.format(python2, get_pip_path, force_reinstall) %}
{%- if install_pip2 and which_python2 and which_pip2 %}
  {%- set install_pip2 = False %}
{%- endif %}
{%- set which_pip3 = pip3 | which %}
{%- set which_python3 = python3 | which %}
{%- set get_pip3 = '{} {} {}'.format(python3, get_pip_path, force_reinstall) %}
{%- if install_pip3 and which_python3 and which_pip3 %}
  {%- set install_pip3 = False %}
{%- endif %}

{%- if on_macos %}
pip-update-path:
   environ.setenv:
     - name: PATH
     - value: '/opt/salt/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/salt/bin:/usr/local/sbin:$PATH'
     - update_minion: True
{%- endif %}

pip-install:
  cmd.run:
    - name: 'echo "Place holder for pip2 and pip3 installs"'
    {%- if install_pip2 or install_pip3 %}
    - require:
      {%- if install_pip2 %}
      - cmd: pip2-install
      {%- endif %}
      {%- if install_pip3 %}
      - cmd: pip3-install
      {%- endif %}
    {%- endif %}

download-get-pip:
  file.managed:
    - name: {{ get_pip_path }}
    - source: https://github.com/pypa/get-pip/raw/309a56c5fd94bd1134053a541cb4657a4e47e09d/get-pip.py
    - skip_verify: true

{%- if install_pip3 %}
pip3-install:
  cmd.run:
    # -c <() because of https://github.com/pypa/get-pip/issues/37
    {%- if on_windows %}
    - name: '{{ get_pip3 }} "pip" "setuptools" "wheel"'
    {%- else %}
    - name: {{ get_pip3 }} pip setuptools wheel
    {%- endif %}
    - cwd: /
    - reload_modules: True
    - require:
      - python3
      - download-get-pip
    {%- if install_pip3 and grains['os'] == 'Ubuntu' and os_major_release >= 18 %}
      - python3-distutils
    {%- endif %}
    {%- if on_debian_7 %}
      - pkg: python-dev
    {%- endif %}
{%- endif %}

{%- if install_pip2 %}
pip2-install:
  cmd.run:
    # -c <() because of https://github.com/pypa/get-pip/issues/37
    {%- if on_windows %}
    - name: '{{ get_pip2 }} "pip" "setuptools" "wheel"'
    {%- else %}
    - name: {{ get_pip2 }} pip setuptools wheel
    {%- endif %}
    - cwd: /
    - reload_modules: True
    - require:
      - python2
      - download-get-pip
    {%- if on_debian_7 %}
      - pkg: python-dev
    {%- endif %}

{%- endif %}
