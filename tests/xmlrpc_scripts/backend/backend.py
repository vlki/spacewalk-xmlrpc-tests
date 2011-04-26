# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file
#
# The common settings of all Spacewalk XML-RPC backend API calls.
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

import sys
import os
import xmlrpclib
import zlib
import StringIO
import base64
import ConfigParser

class ZlibDecodedResponse:
    """
    Response object wrapping the actual httplib.HTTPResponse and
    decoding the content using zlib and base64. 
    """
    def __init__(self, response):
        self.response = response

        encodedString = response.read()

        if response.getheader("Content-Transfer-Encoding", "") == "base64":
            encodedString = base64.b64decode(encodedString)
        
        decodedString = zlib.decompress(encodedString)
        self.stream = StringIO.StringIO(decodedString)

    def read(self, amt=None):
        return self.stream.read(amt)
    
    def close(self):
        return self.stream.close()

    def getheader(self, name, default=None):
        return self.response.getheader(name, default)


class ZlibTransport(xmlrpclib.Transport):
    """
    Transport which looks in Content-Encoding HTTP header and in case
    there is the x-zlib value, wraps the response into ZlibDecodedResponse.
    """
    def parse_response(self, response):
        if response.getheader("Content-Encoding", "") == "x-zlib":
            response = ZlibDecodedResponse(response)
        
        return xmlrpclib.Transport.parse_response(self, response)

configPath = "../../conf/xmlrpc.cfg"
configAbsPath = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), configPath))

config = ConfigParser.RawConfigParser()
config.read(configAbsPath)

# Retrieve values from config file
spacewalkHost = config.get('global', 'host')

client = xmlrpclib.ServerProxy('http://' + spacewalkHost + '/XMLRPC', transport=ZlibTransport())
