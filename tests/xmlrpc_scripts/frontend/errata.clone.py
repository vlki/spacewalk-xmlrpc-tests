#!/usr/bin/env python

# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file
#
# Python script calling the XML-RPC errata.clone of local Spacewalk server.
#
# Usage:
#   ./errata.clone.py session-key channel-label [adv-name [adv-name [...]]]
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

import sys
import xmlrpclib
import getopt
from frontend import client, spacewalkLogin, spacewalkPassword

def main(argv):
    """
    The main function called when this script is executed.
    """
    if len(argv) < 2:
        usage()
        sys.exit(2)

    sessionKey = argv[0]
    channelLabel = argv[1]
    advisoryNames = argv[2:]
   
    errata = client.errata.clone(sessionKey, channelLabel, advisoryNames)

    for erratum in errata:
        print(erratum['advisory_name'])

def usage():
    """
    Prints the usage information.
    """
    print("Python script calling the XML-RPC errata.clone")
    print("of Spacewalk frontend API.")
    print("")
    print("Cloned erratum advisory names are printed by line")
    print("")
    print("Usage:")
    print(" ./errata.clone.py session-key channel-label")
    print("                   [adv-name [adv-name [...]]]")
    print("") 

if __name__ == "__main__":
    main(sys.argv[1:])
