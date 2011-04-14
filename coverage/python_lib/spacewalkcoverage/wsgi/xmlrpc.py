#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file.
#
"""

The wrapper of RHN Satellite/Spacewalk's WSGI handler adding 
the coverage collecting functionality.

"""

import sys
import os

from spacewalkcoverage.spacewalkcoverage import SpacewalkCoverage

# Import the decorated XML-RPC WSGI handler
import wsgi.xmlrpc

def application(environ, start_response):
    cov = SpacewalkCoverage()
    cov.start()

    response_data = wsgi.xmlrpc.application(environ, start_response)

    cov.stop()

    return response_data
