{% set run_on = {
    "CentOS": (6,)
  }
%}

{% set source_dir = salt["pillar.get"]("package_source_dir", "/testing") %}
{% set build_dir = salt["pillar.get"]("package_build_dir", "/tmp/salt-buildpackage") %}
{% set artifact_dir = salt["pillar.get"]("package_artifact_dir", "/tmp/salt-packages") %}

{# This gets overridden below if packages should be built #}
{% set platform = "" %}
{# This argument is for additional, platform-specific arguments #}
{% set additional_args = "" %}
{# Override this in the if/else logic below if the python binary name is
   different (i.e. python26 for CentOS 5, and python2 for Arch) #}
{% set python = "python" %}

{# ######################################################################## #}
{# ################ Figure out if packages should be built ################ #}
{# ######################################################################## #}
{% if grains["os"] in run_on %}

  {% if grains["os"] == "CentOS" %}

    {% if grains["osrelease"]|int in run_on[grains["os"]] %}

    {% set platform = "CentOS" %}
    {% set additional_args = "--spec=" + source_dir + "/tests/pkg/rpm/salt.spec" %}

    {% endif %}

  {% endif %}

{% endif %}

{# ######################################################################## #}
{# ##################### Build packages if necessary ###################### #}
{# ######################################################################## #}
{% if platform %}
run_buildpackage:
  cmd:
    - run
    - name: '{{ python }} {{ source_dir }}/tests/buildpackage.py --platform={{ platform }} --log-level=debug --source-dir={{ source_dir }} --build-dir={{ build_dir }} --artifact-dir={{ artifact_dir }} {{ additional_args }}'
{% endif %}
