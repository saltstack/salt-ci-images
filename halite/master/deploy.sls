{%- from "halite/settings.jinja" import settings with context %}

{{ settings.master_id }}:
  cloud.present:
    - provider: rackspace
    - size: 1 GB Performance
    - image: Ubuntu 12.04 LTS (Precise Pangolin)
    - script_args: -U -M -A {{ grains.get('external_ip') }} -g {{ settings.test_git_url }} git {{ settings.test_git_commit }}
    - minion:
        master: {{ grains.get('external_ip') }}
        grains: {{ settings | yaml }}
    - failhard: True
