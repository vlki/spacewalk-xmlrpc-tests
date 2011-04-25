#!/usr/bin/env python
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file.
#

#
# This script opens the coverage properties file and reads the
# value of configuration property specified by a given parameter.
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

import sys
import os
import ConfigParser

def main(scriptName, argv):
    """
    The main script function.
    """
    if len(argv) != 1:
        usage()
        exit(1)

    configPath = "../conf/coverage.properties"
    fileDirname = os.path.dirname(os.path.abspath(__file__))
    configAbsPath = os.path.abspath(os.path.join(fileDirname, configPath))

    config = ConfigParser.RawConfigParser()
    config.read(configAbsPath)
       
    # Output without trailing newline
    sys.stdout.write(config.get('global', argv[0]))
    exit(0)

def usage():
    """
    Prints the usage information.
    """
    print("This script opens the coverage properties file and reads the")
    print("value of configuration property specified by a given parameter.")
    print("")
    print("Usage:")
    print(" ./get_coverage_config_value.py configuration-property-name")
    print("")
    pass

if __name__ == "__main__":
    main("get_coverage_config_value.py", sys.argv[1:])

