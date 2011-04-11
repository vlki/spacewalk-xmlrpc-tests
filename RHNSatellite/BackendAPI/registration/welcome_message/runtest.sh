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
rlPhaseStartTest "Testing registration.welcome_message without lang"

rlSatelliteXmlRpcBackendRun "registration.welcome_message.py"

# Assert that result is not empty
rlAssertGrep ".\+" "$rlRun_LOG"
rlRun "rm -f $rlRun_LOG"

rlPhaseEnd



# ===================================================================
# Cleanup phase(s)
# ===================================================================
# rlPhaseStartCleanup "Cleanup"

# rlPhaseEnd



rlJournalEnd
rlJournalPrintText
