#!/usr/bin/env python

# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file
#
# Python script calling the XML-RPC channel.software.create
# of Spacewalk frontend API. See usage for more information.
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
    if len(argv) != 6:
        usage()
        sys.exit(2)
    
    client.channel.software.create(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5])

def usage():
    """
    Prints the usage information.
    """
    print("Python script calling the XML-RPC channel.software.create")
    print("of Spacewalk frontend API.")
    print("")
    print("Usage:")
    print(" ./channel.software.create.py session-key label name summary")
    print("                              arch-label parent-label")
    print("") 

if __name__ == "__main__":
    main(sys.argv[1:])
