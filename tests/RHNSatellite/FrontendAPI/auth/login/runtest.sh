#!/bin/bash
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
# 
# For further information see enclosed LICENSE file.
#

#
# The test of auth.login frontend call
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
if rlSatelliteVersionIs "1.2"; then
  rlPhaseStartTest "Testing auth.login of default administrator"
    rlSatelliteSaveTomcat6Log

    rlSatelliteXmlRpcFrontendRun "auth.login.py"

    # Expect the session key of length 36
    rlAssertGrep "[a-z0-9]\{36\}" "$rlRun_LOG"
    rlRun "rm -f $rlRun_LOG"

    rlSatelliteAssertTomcat6LogNotDiffer
  rlPhaseEnd
fi

rlJournalEnd
rlJournalPrintText
