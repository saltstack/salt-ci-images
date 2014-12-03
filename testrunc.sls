{% if grains['os'] == 'Arch' %}
  {% set python = 'python2' %}
{% elif grains['os_family'] == 'RedHat' and grains['osmajorrelease'][0] == '5' %}
  {% set python = 'python26' %}
{% else %}
  {% set python = 'python' %}
{% endif %}
{% set test_git_url =  pillar.get('test_git_url', 'https://github.com/saltstack/salt.git') %}
{% set test_transport = pillar.get('test_transport', 'zeromq') %}
{% set test_transport = pillar.get('test_transport', 'zeromq') %}

include:
  - git.salt

test_cmd:
{%- if 'runtests.run' in salt %}
  runtests.run:
{%- else %}
  cmd.run:
{%- endif %}
    - name: '{{ python }} /testing/tests/runtests.py -v --run-destructive --sysinfo --no-colors --ssh --xml=/tmp/xml-unitests-output --coverage-xml=/tmp/coverage.xml --transport={{ test_transport }}; code=$?; echo "Test Suite Exit Code: ${code}";'
    - order: last
    - require:
      - git: {{ gitsalt.test_git_url }}
    {%- if gitsalt.test_git_url != "https://github.com/saltstack/salt.git" %}
      - cmd: fetch-upstream-tags
    {%- endif %}
    - env:
      - XML_TESTS_OUTPUT_DIR: /tmp/xml-unitests-output

sdist_cmd:
  cmd.run:
    - name: '{{ python }} setup.py sdist'
    - cwd: '/testing'
    - require:
      - cmd: test_cmd
