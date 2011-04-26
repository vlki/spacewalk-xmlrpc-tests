#!/usr/bin/env python

# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file
#
# Python script calling the XML-RPC auth.login of local Spacewalk server.
# If both username and password are omitted, default spacewalk login and
# password is used.
# Usage:
#   ./auth.login.py [-d optional_duration] [username password]
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
    username = spacewalkLogin
    password = spacewalkPassword
    duration = None

    try:
        # there is one optional parameter "duration"
        opts, args = getopt.getopt(argv, "d:", ["duration="])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-d", "--duration"):
            # duration should be Integer param
            duration = int(arg)
    
    if len(args) != 2 and len(args) != 0:
        usage()
        sys.exit(2)
    
    if len(args) == 2: 
        username = args[0]
        password = args[1]

    if duration is None:
        session_key = client.auth.login(username, password)
    else:
        session_key = client.auth.login(username, password, duration)

    print(session_key)

def usage():
    """
    Prints the usage information.
    """
    print("Python script calling the XML-RPC auth.login of local Spacewalk server.")
    print("If both username and password are omitted, default satellite login and")
    print("password is used.")
    print("")
    print("Usage:")
    print(" ./auth.login.py [-d optional_duration] [username password]")
    print("") 

if __name__ == "__main__":
    main(sys.argv[1:])
