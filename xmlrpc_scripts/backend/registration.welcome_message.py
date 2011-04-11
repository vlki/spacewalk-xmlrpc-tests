#!/usr/bin/env python

# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file
#
# Python script calling the XML-RPC registration.welcome_message of Satellite server's
# backend API.
# 
# Has only one optional parameter -- the language of response.
#
# Usage:
#   ./registration.welcome_message.py [language]
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

import sys
from backend import client

def main(argv):
    """
    The main function called when this script is executed.
    """
    if len(argv) > 1:
        usage()
        sys.exit(2)

    if len(argv) == 1:
        welcome_message = client.registration.welcome_message(argv[0])
    else:
        welcome_message = client.registration.welcome_message()

    print(welcome_message)

def usage():
    """
    Prints the usage information.
    """
    print("Python script calling the XML-RPC registration.welcome_message of Satellite server's")
    print("backend API.")
    print("")
    print("Has only one optional parameter -- the language of response.")
    print("")
    print("Usage:")
    print(" ./registration.welcome_message.py [language]")
    print("")

if __name__ == "__main__":
    main(sys.argv[1:])
