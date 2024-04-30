{%- set python3_dir = 'c:\\\\Python310' %}

python3:
  pkg.installed:
    - name: python3_x64
    - version: '3.10.4150.0'
    - extra_install_flags: "TargetDir={{ python3_dir }} Include_doc=0 Include_tcltk=0 Include_test=0 Include_launcher=1 PrependPath=1 Shortcuts=0"
