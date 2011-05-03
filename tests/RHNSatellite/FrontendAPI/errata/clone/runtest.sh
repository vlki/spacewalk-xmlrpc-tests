#!/bin/bash
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
# 
# For further information see enclosed LICENSE file.
#

#
# The test of errata.clone frontend call
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

# Include the common setup
. ./../../../setup.sh

rlJournalStart

# ===================================================================
# Setup Spacewalk
# ===================================================================

rlPhaseStartSetup
    # login as administrator
    rlSatelliteXmlRpcFrontendRun "auth.login.py"
    adminSessionKey=$( cat "$rlRun_LOG" )
    rlRun "rm -f $rlRun_LOG"

    # create test channel
    testChannelLabel="channel-for-errata-clone-test"
    rlSatelliteXmlRpcFrontendRun "channel.software.create.py \
$adminSessionKey $testChannelLabel 'Test channel' 'Test channel summary' \
'channel-ia32' ''"

    # create test user
    rlSatelliteXmlRpcFrontendRun "user.create.py $adminSessionKey \
testuser testuser Test User nobody@example.com"

    # login as the test user
    rlSatelliteXmlRpcFrontendRun "auth.login.py testuser testuser"
    testUserSessionKey=$( cat "$rlRun_LOG" )

    # create two errata and publish them in test channel
    erratumFirstName="Advisory name 1"
    erratumSecondName="Advisory name 2"
    rlSatelliteXmlRpcFrontendRun "errata.create.py $adminSessionKey \
'Synopsis' '$erratumFirstName' 1 'Security Advisory' 'Product' 'Topic' \
'Description' 'References' 'Notes' 'Solution' 1 $testChannelLabel"
    rlSatelliteXmlRpcFrontendRun "errata.create.py $adminSessionKey \
'Synopsis' '$erratumSecondName' 1 'Security Advisory' 'Product' 'Topic' \
'Description' 'References' 'Notes' 'Solution' 1 $testChannelLabel"
rlPhaseEnd

# ===================================================================
# Do the testing
# ===================================================================

rlPhaseStartTest "Unknown channel should raise error"
    rlSatelliteXmlRpcFrontendRun "errata.clone.py $adminSessionKey \
some-unknown-channel-label" 1

    # Expect the error with message No such channel
    rlAssertGrep "No such channel" "$rlRun_LOG"
    rlRun "rm -f $rlRun_LOG"
rlPhaseEnd

# ===================================================================

rlPhaseStartTest "Cloning erratas of channel user have not privileges for"
    rlSatelliteXmlRpcFrontendRun "errata.clone.py $testUserSessionKey \
$testChannelLabel" 1

    # Excpect error that user does not have permissions
    rlAssertGrep "You do not have permissions to perform this action" \
                 "$rlRun_LOG"
    rlRun "rm -f $rlRun_LOG"
rlPhaseEnd

# ===================================================================

rlPhaseStartTest "No erratas to clone should not be a problem"
    rlSatelliteSaveTomcat6Log

    rlSatelliteXmlRpcFrontendRun "errata.clone.py $adminSessionKey \
$testChannelLabel"

    rlRun "rm -f $rlRun_LOG"

    rlSatelliteAssertTomcat6LogNotDiffer
rlPhaseEnd

# ===================================================================

rlPhaseStartTest "Clone two erratas"
    rlSatelliteSaveTomcat6Log

    rlSatelliteXmlRpcFrontendRun "errata.clone.py $adminSessionKey \
$testChannelLabel '$erratumFirstName' '$erratumSecondName'"

    # Get names of just created errata
    clonedErratumFirstName=$( echo | awk 'NR==1 {print;exit}' \
"$rlRun_LOG" )
    clonedErratumSecondName=$( echo | awk 'NR==2 {print;exit}' \
"$rlRun_LOG" )

    # Remove errata
    rlSatelliteXmlRpcFrontendRun "errata.delete.py $adminSessionKey \
'$clonedErratumFirstName'"
    rlSatelliteXmlRpcFrontendRun "errata.delete.py $adminSessionKey \
'$clonedErratumSecondName'"

    rlRun "rm -f $rlRun_LOG"

    rlSatelliteAssertTomcat6LogNotDiffer
rlPhaseEnd

# ===================================================================
# Clean after tests
# ===================================================================

rlPhaseStartCleanup
    # remove errata
    rlSatelliteXmlRpcFrontendRun "errata.delete.py $adminSessionKey \
'$erratumFirstName'"
    rlSatelliteXmlRpcFrontendRun "errata.delete.py $adminSessionKey \
'$erratumSecondName'"

    # logout the test user
    rlSatelliteXmlRpcFrontendRun "auth.logout.py $testUserSessionKey"

    # delete the test user
    rlSatelliteXmlRpcFrontendRun "user.delete.py $adminSessionKey testuser"

    # delete the test channel
    rlSatelliteXmlRpcFrontendRun "channel.software.delete.py \
$adminSessionKey $testChannelLabel"

    # logout administrator
    rlSatelliteXmlRpcFrontendRun "auth.logout.py $adminSessionKey"
rlPhaseEnd

rlJournalEnd
rlJournalPrintText
