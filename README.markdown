Spacewalk XML-RPC tests
=======================

Tests of Spacewalk's XML-RPC interface. Contains two modules -- one contains the actual tests and the other one the coverage tools.


## Tests module ##

The tests which resides in tests module are based on [BeakerLib](https://fedorahosted.org/beaker/wiki/BeakerLib). It is not dependent on coverage module and therefore tests can be run on their own.

### Requirements ###

RPMs:

* beakerlib

### Installation ###

The only thing you have to do is to provide configuration for XML-RPC client. Copy the `tests/conf/xmlrpc.cfg.dist` to `tests/conf/xmlrpc.cfg` and update it with your RHN Satellite/Spacewalk-specific configuration.

### Running the tests ###

Just call the `./tests/runtests.sh` which will run all tests in tests directory. It will NOT collect any coverage data.

## Coverage module ##

The coverage module can be installed before running the tests and it then collects the data of executed parts of code. Since RHN Satellite/Spacewalk has Java as well as Python codebase, the coverage module injects both of these parts of server and evaluates the coverage separately. The coverage module is dependent on the tests module as it runs all the tests there.

### Requirements ###

RPMs:

* ant
* ant-nodeps
* cobertura
* python-coverage

### Installation ###


First you need to set the needed coverage configuration in `coverage/conf/coverage.properties`. The default values are provided in `coverage/conf/coverage.properties.dist` and you are encouraged to use it.

Then just run `sudo ./coverage/install.sh`. It will prepare the system for measuring the coverage of Python and Java codebase.

### Running the tests with coverage ###

In order to see coverage of the tests execute `./coverage/runtests.sh`. It will run all the tests in the tests module and evaluate the coverage.

### Uninstallation ###

Run `sudo ./coverage/uninstall.sh`. It will rollback changes made during installation.
