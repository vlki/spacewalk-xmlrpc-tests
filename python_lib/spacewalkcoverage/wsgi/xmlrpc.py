
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
