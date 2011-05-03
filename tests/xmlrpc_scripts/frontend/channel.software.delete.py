#!/usr/bin/env python

# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file
#
# Python script calling the XML-RPC channel.software.delete
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
    if len(argv) != 2:
        usage()
        sys.exit(2)
    
    client.channel.software.delete(argv[0], argv[1])

def usage():
    """
    Prints the usage information.
    """
    print("Python script calling the XML-RPC channel.software.delete")
    print("of Spacewalk frontend API.")
    print("")
    print("Usage:")
    print(" ./channel.software.delete.py session-key channel-label")
    print("") 

if __name__ == "__main__":
    main(sys.argv[1:])
