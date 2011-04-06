#!/bin/bash

#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

# Include the BeakerLib environment
. /usr/share/beakerlib/beakerlib.sh

# Set full test name
TEST=/auth/login

# Set administrator credentials
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin

rlJournalStart

# ===================================================================
# Setup phase(s)
# ===================================================================
# rlPhaseStartSetup "Configure X"

# Some setup
# rlAssertRpm "spacewalk-schema" || rlDie "Package spacewalk-schema not installed, dying."

# rlPhaseEnd



# ===================================================================
# Do the testing
# ===================================================================
rlPhaseStartTest "Testing auth.login of existing administrator"

# Expect successful run
rlRun "./auth.login.py vlcek vlcek > stdout" 0

# Expect the session key of length 36
rlAssertGrep "[a-z0-9]\{36\}" "stdout"

rlPhaseEnd



# ===================================================================
# Cleanup phase(s)
# ===================================================================
# rlPhaseStartCleanup

# rlRun "do_some_cleanup"   # e.g. remove temp files and so on

# rlPhaseEnd



rlJournalEnd
rlJournalPrintText
