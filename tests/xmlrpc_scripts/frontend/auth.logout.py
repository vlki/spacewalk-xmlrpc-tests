#!/usr/bin/env python

# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file
#
# Python script calling the XML-RPC auth.logout of local Spacewalk server.
#
# Usage:
#   ./auth.logout.py session-key
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

import sys
import xmlrpclib
import getopt
from frontend import client

def main(argv):
    """
    The main function called when this script is executed.
    """
    if len(argv) != 1:
        usage()
        sys.exit(2)

    client.auth.logout(argv[0])

def usage():
    """
    Prints the usage information.
    """
    print("Python script calling the XML-RPC auth.logout of local Spacewalk server.")
    print("")
    print("Usage:")
    print(" ./auth.login.py session-key")
    print("") 

if __name__ == "__main__":
    main(sys.argv[1:])
