add_known_etc_hosts_entries:
  file.append:
    {%- if grains['os'] != 'Windows' %}
    - name: /etc/hosts
    {%- else %}
    - name: C:\\Windows\\System32\\drivers\\etc\hosts
    {%- endif %}
    - text:
      - "::1 ipv6.saltstack-test dualstack.saltstack-test"
      - "127.0.0.1 ipv4.saltstack-test dualstack.saltstack-test"
