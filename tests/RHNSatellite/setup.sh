#!/bin/bash
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
# 
# For further information see enclosed LICENSE file.
#

#
# The common setup of BeakerLib tests.
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

# Include the BeakerLib environment with Satellite XML-RPC plugin
. /usr/share/beakerlib/beakerlib.sh
. ./../../../../beakerlib_plugins/beakerlib-satellite-xmlrpc.sh

SATELLITE_XMLRPC_SCRIPTS="./../../../../xmlrpc_scripts"

rlLoadConfigProperty "./../../../../conf/xmlrpc.cfg" "version"
SPACEWALK_VERSION=$rlLoadConfigProperty_VALUE
