{%- set salt_dir = salt['config.get']('python_install_dir', 'c:\\salt').rstrip('\\') %}
{%- set scripts_dir = salt_dir | path_join('bin', 'Scripts') %}
{%- set site_packages = salt_dir | path_join('Lib', 'site-packages') %}

pywin32:
  pip.installed:
    - name: pywin32==223

{%- for fname in salt.file.find(site_packages | path_join('pywin32_system32'), name='*.dll') %}
move-{{ fname.split('\\')[-1] }}:
  file.rename:
    - name: {{ fname.replace('pywin32_system32', 'win32') }}
    - source: {{ fname }}
    - require:
      - pip: pywin32
    - require_in:
      - file: remove-pywin32_system32
      - file: remove-pythonwin
{%- endfor %}


remove-pywin32_system32:
  file.absent:
    - name: "{{ (site_packages | path_join('pywin32_system32')).replace('\\', '\\\\') }}"

remove-pythonwin:
  file.absent:
    - name: "{{ (site_packages | path_join('pythonwin')).replace('\\', '\\\\') }}"

{%- for fname in salt.file.find(scripts_dir, iname='pywin32_*') %}
remove-{{ fname.split('\\')[-1] }}:
  file.absent:
    - name: {{ fname }}
    - require:
      - pip: pywin32
{%- endfor %}
