{%- from "apache/init.sls" import apache with context %}

include:
  - apache


salt-minion:
  service:
    - running
    - reload: True
    - require:
      - pkg: {{ apache }}
    - failhard: True

