{#- Make sure there's at least one state entry in the state file #}
noop-{{ sls }}:
  test.succeed_without_changes
