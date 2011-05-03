#!/usr/bin/env python

# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file
#
# Python script calling the XML-RPC user.create
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
    if len(argv) < 6 or len(argv) > 7:
        usage()
        sys.exit(2)

    if len(argv) == 7:
        argv[6] = int(argv[6])

    user = client.user.create(*argv)

def usage():
    """
    Prints the usage information.
    """
    print("Python script calling the XML-RPC user.create")
    print("of Spacewalk frontend API.")
    print("")
    print("Usage:")
    print(" ./user.create.py session-key login password first-name last-name")
    print("                              email [0|1 .. use-pam-auth]")
    print("") 

if __name__ == "__main__":
    main(sys.argv[1:])
