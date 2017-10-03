/usr/bin/kitchen:
  file.managed:
    - source: salt://kitchen/kitchen.py
    - template: jinja
    - mode: 755
