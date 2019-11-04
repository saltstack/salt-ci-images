=======================
Salt Jenkins State Tree
=======================

|build|

Salt states used to run Jenkins tests.

The salt-jenkins state tree is used to configure and prepare the testing VMs used to run Salt's test suite on
`Salt's Jenkins system`_. These states install the testing requirements needed
to execute the tests themselves, any packages and dependencies needed for particular module or state tests to
run, set up configuration files, and clone Salt into the ``/testing`` directory.

Occasionally, new packages need to be installed on the testing VMs to ensure that particular tests will run.
For example, if a contributor adds a test file for Salt's docker execution module, the ``docker`` package needs
to be installed on the test VMs. This repository is the place to perform that package installation by adding
a state.


Locally Running States
======================

You can clone this repository, and, as long as you already have salt installed, you can run this state tree
directly (instead of using ``gitfs``).

For example::

    salt-call state.sls git.salt pillar="{py3: true, test_transport: zeromq, with_coverage: true}"

The minion configuration file also needs to be edited to direct the ``file_roots`` to the ``salt-jenkins`` cloned
directory. For example, if the ``salt-jenkins`` repository was cloned directly into the ``/root`` dirctory, the
minion config file would look like this::

    # /etc/salt/minion

    file_roots:
      base:
        - /root/salt-jenkins

This is possible due to the fact that included in this state tree repository there are ``Saltfile`` and ``minion``
configuration files which set everything up in order to run ``salt-call`` locally against this state tree.


Contributing
============

The ``salt-jenkins`` project is welcome and open to contributions.

The ``salt-jenkins`` repository has a few openly maintained branches. These correspond to the actively maintained
release branches in the `Salt project`_. This helps stabilize the testing
environments that the ``salt-jenkins`` states configure on the test VMs running at
`jenkinsci.saltstack.com`_.

There is a node located in Salt's Jenkins installation configured to run the tests for each supported Salt
release branch. In turn, each node is configured to run the ``salt-jenkins`` state tree based on the Salt release
branch it supports.

For example, the Jenkins node labeled ``2016_3`` runs tests against the HEAD of the ``2016.3`` branch of Salt. This
same ``2016_3`` node is configured to run the ``salt-jenkins`` state tree using the ``2016.3`` branch of the
``salt-jenkins`` repository.

**Note: The "master" branch of the "salt-jenkins" repository is used to test the "master" branch of Salt.**

Which Salt Jenkins Branch?
--------------------------

GitHub will open pull requests against Salt Jenkins's main branch, ``master``, by default. Contributions to the
Salt Jenkins state tree should be added to the oldest supported branch that requires the change.

For example, imagine a new execution module was added to the ``master`` branch in Salt, along with tests for
the new module. The new module requires a dependency that is not currently installed by the Salt Jenkins
states. The new state(s) would need to be added to the ``master`` branch of Salt Jenkins.

If new tests are written against an older release branch in Salt, such as the ``2016.11`` branch, then the
change for the Salt Jenkins states needs to also be submitted against the ``2016.11`` branch in the
``salt-jenkins`` repository.

Merge Forward Policy
~~~~~~~~~~~~~~~~~~~~

The Salt Jenkins repository follows a "Merge Forward" policy. The merge-forward behavior means that changes
that are submitted to older "release" branches will automatically be merged forward into the newer branches.
(The Salt repository follows this same behavior.) This makes is easy for contributors to make only one
pull-request against an older branch, but allow the change to propagate to all ``salt-jenkins`` branches as the
tests make their way forward in the Salt repository.

Here's a simple example of changes merging forward from older branches to newer branches, where the ``HEAD`` of
each branch is merged into the directly newer branch::

    master    *---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*------------>
                                                                 /
                                                                / (Merge Forward from 2016.11 to master)
                                                               /
    2016.11   *---*---*---*---*---*---*---*---*---*---*---*---*
                                         /
                                        / (Merge Forward from 2016.3 to 2016.11)
                                       /
    2016.3    *---*---*---*---*---*---*


.. _jenkinsci.saltstack.com: https://jenkinsci.saltstack.com/
.. _Salt project: https://github.com/saltstack/salt
.. _Salt's Jenkins system: https://jenkinsci.saltstack.com/\
.. |build|  image:: https://drone.saltstack.com/api/badges/saltstack/salt-jenkins/status.svg?ref=refs/heads/master
    :target: https://drone.saltstack.com/saltstack/salt-jenkins
    :alt: Build status on Linux
