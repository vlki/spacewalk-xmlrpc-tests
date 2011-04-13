#
#
#

from spacewalkcoverage.spacewalkcoverage import SpacewalkCoverage

# Import the decorated server
import spacewalk.server.apacheServer

cov = SpacewalkCoverage()

open('/tmp/running-mod-python', 'w').close()

def HeaderParserHandler(req):
    cov.start()
    response = spacewalk.server.apacheServer.HeaderParserHandler(req)
    cov.stop()
    return response

def Handler(req):
    cov.continueStart()
    response = spacewalk.server.apacheServer.Handler(req)
    cov.stop()
    return response

def CleanupHandler(req):
    cov.continueStart()
    response = spacewalk.server.apacheServer.CleanupHandler(req)
    cov.stop()
    return response

# Keep log handler intact
LogHandler = spacewalk.server.apacheServer.LogHandler
