# Arch Linux on some clouds has a default encoding of ASCII
# This is not typical in production, so set this to UTF-8 instead
#
# This will cause integration.shell.matcher.MatchTest.test_salt_documentation_arguments_not_assumed
# to fail if not set correctly.

{%- if grains['os'] in ('MacOS') %}
mac_locale:
  file.blockreplace:
    - name: /etc/profile
    - marker_start: #------ start locale zone ------
    - marker_end: #------ endlocale zone ------
    - content: |
        export LANG=en_US.UTF-8
{%- else %}

{% set suse = True if grains['os_family'] == 'Suse' else False %}
{% if suse %}
suse_local:
  pkg.installed:
    - name: glibc-locale
{% endif %}

us_locale:
  locale.present:
    - name: en_US.UTF-8

default_locale:
  locale.system:
    - name: en_US.UTF-8
    - require:
      - locale: us_locale

{%- endif %}
