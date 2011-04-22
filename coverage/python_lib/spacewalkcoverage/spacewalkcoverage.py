#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file.
#
"""

This module provides the SpacewalkCoverage class wrapping the setup of 
the coverage module for use with Spacewalk handlers.

"""

import os
import getpass
import coverage
import ConfigParser

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
        Initializes the Coverage object and loads the configuration. 
        In order to start the measurements, method start must be called.
        """
        configPath = "../../conf/coverage.properties"
        configAbsPath = os.path.abspath(os.path.join(
            os.path.dirname(os.path.abspath(__file__)), configPath))

        config = ConfigParser.RawConfigParser()
        config.read(configAbsPath)
       
        self.datafilePath = config.get('global', 'python.datafile.path')
        self.cov = None

    def start(self):
        """
        Starts coverage session. If there are any data in datafile, they
        will be loaded and combined with current coverage measurements.
        """
        if self.cov is not None:
            raise InvalidStateError(
                "Cannot start coverage. It has been probably started before.")
        
        # "touch" the data file and set write permissions for everyone
        open(self.datafilePath, "w").close()
        os.chmod(self.datafilePath, 0777)

        sourceModules = ["spacewalk", "server"]
        
        self.cov = coverage.coverage(data_file=self.datafilePath, 
                                     cover_pylib=True, source=sourceModules,
                                     branch=True)
        self.cov.load()
        self.cov.start()

    def stop(self):
        """
        Stops the coverage measurements and saves collected data into datafile.
        """
        if self.cov is None:
            raise InvalidStateError(
                "Cannot stop coverage. It has not been probably started yet.")

        self.cov.stop()
        self.cov.save()

        self.cov = None
