
import sys
import os
from coverageSetup import Coverage

# Add the directory with decorated WSGI handlers to path
sys.path.append("/usr/share/rhn/wsgi")

# Import the decorated XML-RPC WSGI handler
import xmlrpc

def application(environ, start_response):
    cov = Coverage()
    cov.start()

    response_data = xmlrpc.application(environ, start_response)

    cov.stop()

    return response_data
