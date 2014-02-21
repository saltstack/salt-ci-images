{%- from "halite/settings.jinja" import settings with context %}

{%- set halite_master_ip = salt['saltutil.cmd'](settings.master_id, 'grains.get', arg=('external_ip',))[settings.master_id]['ret'] %}

{%- for num in range(0, settings.num_minions) %}
test-halite-minion-{{ settings.build_id }}-{{ num }}:
  cloud.present:
    - provider: rackspace
    - size: 1 GB Performance
    - image: Ubuntu 12.04 LTS (Precise Pangolin)
    - script_args: -U -A {{ halite_master_ip }} -g {{ settings.git_url }} git {{ settings.git_commit }}
    - minion:
        master: {{ halite_master_ip }}
        grains: {{ settings | yaml }}
    - failhard: True
{% endfor %}
