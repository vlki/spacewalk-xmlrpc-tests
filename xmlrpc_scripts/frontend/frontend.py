#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
# 
# For further information see enclosed LICENSE file
# 
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

import sys
import os
import ConfigParser
import xmlrpclib

configPath = "../../conf/xmlrpc_frontend.cfg"
configAbsPath = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), configPath))

config = ConfigParser.RawConfigParser()
config.read(configAbsPath)

# Retrieve values from config file
satelliteHost = config.get('Satellite', 'host')
satelliteLogin = config.get('Satellite', 'login')
satellitePassword = config.get('Satellite', 'password')

satelliteFrontendApiUrl = 'http://' + satelliteHost + '/rpc/api'

# Client is available for export
client = xmlrpclib.ServerProxy(satelliteFrontendApiUrl)
