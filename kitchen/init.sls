/usr/local/bin/kitchen:
  file.managed:
    - source: salt://kitchen/kitchen.py
    - mode: 755
