
import coverage

class InvalidStateError(Exception):
    """
    The error thrown when Coverage object's methods are called in bad order.
    """
    pass

class SpacewalkCoverage():
    """
    The SpacewalkCoverage class wrapping the setup and calls of coverage
    module.
    """

    def __init__(self):
        """
        Initializes the Coverage object. In order to start the measurements,
        method start must be called.
        """
        self.cov = None

    def start(self):
        """
        Starts new coverage session. If there are any data in datafile,
        they will be erased.
        """
        if self.cov is not None:
            raise InvalidStateError("Cannot start coverage. It has been probably started before.")

        self.cov = self._createCov()
        self.cov.erase()
        self.cov.start()

    def continueStart(self):
        """
        Continues in coverage session. It means that if there is a datafile,
        its data will be read and combined with current coverage measurements.
        """
        if self.cov is not None:
            raise InvalidStateError("Cannot continue coverage. It has been probably started before.")

        self.cov = self._createCov()
        self.cov.load()
        self.cov.start()

    def _createCov(self):
        """
        Creates the coverage object.
        """
        dataFilePath = "/var/opt/spacewalk-xmlrpc-tests/coverage/python.coverage.datafile"
        sourceModules = ["spacewalk", "server"]

        return coverage.coverage(data_file=dataFilePath, cover_pylib=True, source=sourceModules)
        
    def stop(self):
        """
        Stops the coverage measurements and saves collected data into datafile.
        """
        if self.cov is None:
            raise InvalidStateError("Cannot stop coverage. It has not been probably started yet.")

        self.cov.stop()
        self.cov.save()

        self.cov = None
