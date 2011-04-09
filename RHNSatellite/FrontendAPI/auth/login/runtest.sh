#!/bin/bash

#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

# Include the BeakerLib environment
. /usr/share/beakerlib/beakerlib.sh

# With Satellite plugin
. ./../../../../beakerlib_plugins/beakerlib-satellite-xmlrpc.sh

# Set full test name
TEST=/auth/login

# Set administrator credentials
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin

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

rlSatelliteXmlRpcFrontendRun "auth.login.py vlcek vlcek"

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
