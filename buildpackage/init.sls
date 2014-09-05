{%
  run_on = {
    'CentOS': ('6',)
  }
%}

{% set platform = None %}
{% set additional_args = '' %}

{% if grains['os'] in run_on %}

  {% if grains['os'] == 'CentOS' %}

    {% if grains['osmajorrelease'] in run_on[grains['os']] %}
    {% set platform = 'CentOS' %}
    {% set additional_args = '--spec=/tmp/salt.spec' %}

/tmp/salt.spec:
  file:
    - managed
    - source: salt://buildpackage/files/centos/salt.spec
    - user: root
    - group: root
    - mode: 644
    - require_in:
      - cmd: buildpackage.py

    {% endif %}

  {% endif %}

{% endif %}


{% if platform is not None %}
/tmp/buildpackage.py:
  cmd:
    - script
    - source: salt://buildpackage/files/buildpackage.py
    - args: '--platform={{ platform }} --log-level=debug --source-dir=/testing --dest-dir=/tmp/saltpkg {{ additional_args }}'
{% endif %}
