{% set git_url = pillar.get('git_url', 'https://github.com/saltstack/salt.git') %}
{% set git_commit = pillar.get('git_commit', 'develop') %}
{% set build_id = pillar.get('build_id', '0000') %}

test-halite-master-{{ build_id }}:
  cloud.present:
    provider: rackspace
    size: 1 GB Performance
    image: Ubuntu 12.04 LTS (Precise Pangolin)
    script_args: -U -M -A {{ grains.get('external_ip') }} -g {{ git_url }} git {{ git_commit }}
