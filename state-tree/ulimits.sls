{%- if grains['kernel'] == 'Linux' %}
ulimits-nofile:
  file.managed:
    - name: /etc/security/limits.d/83-nofile.conf
    - mode: 644
    - makedirs: True
    - contents: 'root - nofile 1048576'
{%- elif grains['kernel'] == 'Darwin' %}
set limits for launchctl:
  cmd.run:
    - name: launchctl limit maxfiles 10240 unlimited
  file.append:
    - name: /etc/launchd.conf
    - text: limit maxfiles 10240 unlimited
{%- endif %}
