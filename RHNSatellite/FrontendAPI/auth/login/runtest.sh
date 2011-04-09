#!/bin/bash

#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

# Include the BeakerLib environment with Satellite XML-RPC plugin
. /usr/share/beakerlib/beakerlib.sh
. ./../../../../beakerlib_plugins/beakerlib-satellite-xmlrpc.sh

# Set full test name
TEST=/auth/login

SATELLITE_XMLRPC_SCRIPTS="./../../../../xmlrpc_scripts"

rlJournalStart

# ===================================================================
# Setup phase(s)
# ===================================================================
# rlPhaseStartSetup "Setup"

# rlPhaseEnd



# ===================================================================
# Do the testing
# ===================================================================
rlPhaseStartTest "Testing auth.login of existing administrator"

rlSatelliteSaveTomcat6Log

rlSatelliteXmlRpcFrontendRun "auth.login.py $SATELLITE_LOGIN $SATELLITE_PASSWORD"

# Expect the session key of length 36
rlAssertGrep "[a-z0-9]\{36\}" "$rlRun_LOG"
rlRun "rm -f $rlRun_LOG"

rlSatelliteAssertTomcat6LogNotDiffer

rlPhaseEnd



# ===================================================================
# Cleanup phase(s)
# ===================================================================
# rlPhaseStartCleanup "Cleanup"

# rlPhaseEnd



rlJournalEnd
rlJournalPrintText
