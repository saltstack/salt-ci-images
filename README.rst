============
Salt Jenkins
============

These are states and related packer configuration for creating golden images and containers that are used for testing
salt.  These also hold the states that are run at the beginning of the cloud tests.


Contributing
============

The ``salt-jenkins`` project is welcome and open to contributions.  All PRs should go into the master branch.

If you want to open a PR to this repo that the CI should run on, push your change to a branch on the upstream repo
(https://github.com/saltstack/salt-jenkins).  CI does not run on PRs from forks.  If you are unable to do that, open
your change from a fork and ask someone on the core team to push your changes to a branch on the upstream repo after
they have read through and agree with the changes and then open a PR from that branch.

If you are only making a doc change, or a cloud-test change, or something that doesn't need the CI to run, just opening
a PR from a fork is fine.


Salt Jenkins State Tree
=======================

Salt states used to run Jenkins tests.

The salt-jenkins state tree is used to configure and prepare the testing VMs used to run Salt's test suite on
`Salt's Jenkins system`_. These states install the testing requirements needed
to execute the tests themselves, any packages and dependencies needed for particular module or state tests to
run, set up configuration files, and clone Salt into the ``/testing`` directory.

Occasionally, new packages need to be installed on the testing VMs to ensure that particular tests will run.
For example, if a contributor adds a test file for Salt's docker execution module, the ``docker`` package needs
to be installed on the test VMs. This repository is the place to perform that package installation by adding
a state.

.. _Salt's Jenkins system: https://jenkins.saltproject.io/
