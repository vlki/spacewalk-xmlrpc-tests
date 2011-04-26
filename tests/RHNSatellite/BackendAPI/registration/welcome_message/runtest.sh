#!/bin/bash
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
# 
# For further information see enclosed LICENSE file.
#

#
# The test of registration.welcome_message backend call
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

# Include the common setup
. ./../../../setup.sh

# Set full test name
TEST=/auth/login

rlJournalStart

# ===================================================================
# Do the testing
# ===================================================================
rlPhaseStartTest "Testing registration.welcome_message without lang"

rlSatelliteSaveHttpdErrorLog

rlSatelliteXmlRpcBackendRun "registration.welcome_message.py"

# Assert that result is not empty
rlAssertGrep ".\+" "$rlRun_LOG"
rlRun "rm -f $rlRun_LOG"

rlSatelliteAssertHttpdErrorLogNotDiffer

rlPhaseEnd

rlJournalEnd
rlJournalPrintText
