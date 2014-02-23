{% from "halite/settings.jinja" import settings with context %}

{% for num in range(0, settings.num_minions) %}
test-halite-minion-{{ settings.build_id }}-{{ num }}:
  cloud.absent
{% endfor %}
