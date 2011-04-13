Spacewalk XML-RPC tests
=======================

BeakerLib based tests of Spacewalk's XML-RPC interface. Together with the tests
is evaluated also the code coverage.

Requirements
------------

RPMs:

* ant
* ant-nodeps
* cobertura
* beakerlib
* python-coverage

Installation
------------

Just run `sudo ./install.sh`. It will prepare the system for measuring the coverage of Python and Java codebase.

Uninstallation
--------------

Run `sudo ./uninstall.sh`. It will rollback changes made during installation.
