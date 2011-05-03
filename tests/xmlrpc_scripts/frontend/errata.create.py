#!/usr/bin/env python

# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file
#
# Python script calling the XML-RPC errata.create
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
    if len(argv) != 13:
        usage()
        sys.exit(2)
  
    sessionKey = argv[0]
    
    struct = dict()
    struct['synopsis'] = argv[1]
    struct['advisory_name'] = argv[2]
    struct['advisory_release'] = int(argv[3])
    struct['advisory_type'] = argv[4]
    struct['product'] = argv[5]
    struct['topic'] = argv[6]
    struct['description'] = argv[7]
    struct['references'] = argv[8]
    struct['notes'] = argv[9]
    struct['solution'] = argv[10]
    
    publish = bool(int(argv[11]))
    channels = argv[12].split(',')

    # not implemented
    bugs = []
    keywords = []
    packages = []

    errata = client.errata.create(sessionKey, struct, bugs, keywords, packages, publish, channels)

    print(errata['id'])

def usage():
    """
    Prints the usage information.
    """
    print("Python script calling the XML-RPC errata.create")
    print("of Spacewalk frontend API.")
    print("")
    print("Prints the ID of created erratum.")
    print("")
    print("Usage:")
    print(" ./errata.create.py session-key synopsis advisory-name")
    print("                    advisory-release advisory-type product")
    print("                    topic description references notes solution")
    print("                    [0|1 .. publish] channel-labels ")
    print("") 

if __name__ == "__main__":
    main(sys.argv[1:])
