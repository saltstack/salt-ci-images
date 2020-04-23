# os-imager
Packer image templates for the Salt test suite

[![Build Status](https://drone.saltstack.com/api/badges/saltstack/os-imager/status.svg)](https://drone.saltstack.com/saltstack/os-imager)

## Branches
These are intended to always be kept separate

* master - base golden images ( just updates and vim, used by ci branch )
* ci - golden images used jenkins for the vm's that kitchen-salt spins up
* jenkins-slaves - images used by jenkins ec2 plugin that kitchen-salt is run from

## Pre Commit Hook

Be sure to install pre-commit in order to prevent checking in AWS credentials.
On the root of the cloned repository do:

```
pip install pre-commit
pre-commit install
```

That's it! And you only have to do it once after cloning the repository.

### See it in action

[![asciicast](https://asciinema.org/a/0Vh2TagppgfpElekWAdfBPzUD.svg)](https://asciinema.org/a/0Vh2TagppgfpElekWAdfBPzUD)
