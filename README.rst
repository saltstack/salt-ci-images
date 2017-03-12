salt-jenkins
============

Salt states used to run jenkins tests

Locally Running States
----------------------

You can clone this repository, and, as long as you already have salt installed, you can
run this state tree directly(instead of using gitfs).

For example:

.. code-block: sh

    salt-call state.sls git.salt pillar="{py3: true, test_transport: zeromq, with_coverage: true}"


This is possible due to the fact that included in this state tree repository there's a `Saltfile` and a `minion`
configuration files which sets everything up in order to run salt-call locally against this state tree.
