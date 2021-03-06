#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file.
#
"""

The wrapper of the RHN Satellite/Spacewalk's mod_python handler
adding the coverage collecting functionality.

"""

from spacewalkcoverage.spacewalkcoverage import SpacewalkCoverage

# Import the decorated server
import spacewalk.server.apacheServer

cov = SpacewalkCoverage()

def HeaderParserHandler(req):
    cov.start()
    response = spacewalk.server.apacheServer.HeaderParserHandler(req)
    cov.stop()
    return response

def Handler(req):
    cov.start()
    response = spacewalk.server.apacheServer.Handler(req)
    cov.stop()
    return response

def CleanupHandler(req):
    cov.start()
    response = spacewalk.server.apacheServer.CleanupHandler(req)
    cov.stop()
    return response

# Keep log handler intact
LogHandler = spacewalk.server.apacheServer.LogHandler
