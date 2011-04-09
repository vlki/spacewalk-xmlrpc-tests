#!/bin/bash

# beakerlib-satellite-xmlrpc.sh - BeakerLib extension for RHN Satellite XML-RPC tests
# Authors: Jan Vlcek <xvlcek03@>
#
# Description: Extends BeakerLib with rlSatellite* functions
#
# TODO: license?

: <<=cut
=pod

=head1 NAME

beakerlib-satellite-xmlrpc.sh - BeakerLib extension for RHN Satellite XML-RPC tests

=head1 DESCRIPTION

This file contains functions related directly to testing. These functions are
non-specialized asserts, as well as several other functions related to testing.  

This file contains functions for easier testing of XML-RPC interface of
RHN Satellite server.

=head1 FUNCTIONS

=cut

Tomcat6LogFile="/var/log/tomcat6/catalina.out"

# TODO: which path is default?
SATELLITE_XMLRPC_SCRIPTS=${SATELLITE_XMLRPC_SCRIPTS:-"/some/default/path"}

SATELLITE_VERSION=${SATELLITE_VERSION:-"1.2"}

SATELLITE_SERVER_HOST=${SATELLITE_SERVER_HOST:-"localhost"}
SATELLITE_LOGIN=${SATELLITE_LOGIN:-"admin"}
SATELLITE_PASSWORD=${SATELLITE_PASSWORD:-"redhat"}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Internal Stuff
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

__INTERNAL_LogAndJournalPass() {
    rljAddTest "$1" "PASS"
}

__INTERNAL_LogAndJournalFail() {
    rljAddTest "$1 $2" "FAIL"
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# rlSatelliteXmlRpcFrontendRun                                                                 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
: <<=cut                                                                       
=pod                                                                           

=head3 rlSatelliteXmlRpcFrontendRun

Run the given XML-RPC script from library (actual path is affected by version
of RHN Satellite) against Satellite frontend API.

    rlSatelliteXmlRpcFrontendRun script

Output of the script is accessible in file of name specified in $rlRun_LOG 
variable. Caller is responsible for removing the file.

=over

=item script

The script which should be run from library, e.g. "auth.login.py admin redhat".

=back

Returns 0 and asserts PASS if the return value of script is 0 (FAIL otherwise).

=cut

rlSatelliteXmlRpcFrontendRun(){
    local scriptName=$( cut -d" " -f1 <<< $1 )
    local scriptExpanded=""
    local basePath="$SATELLITE_XMLRPC_SCRIPTS/frontend"
    
    if [ -e "$basePath/$SATELLITE_VERSION/$scriptName" ]; then
        scriptExpanded="$basePath/$SATELLITE_VERSION/$1"
    else
        scriptExpanded="$basePath/$1"
    fi

    # resolve the absolute path
    scriptExpanded=$( readlink -f "$scriptExpanded" )

    rlRun -s -l -t "$scriptExpanded" 0
    return 0
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# rlSatelliteSaveTomcat6Log
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rlSatelliteSaveTomcat6Log(){
    rlRun "Tomcat6LogSaved=\`mktemp\`" 0 \
          "Creating the temporary file for tomcat6 log file"
    rlRun "cat $Tomcat6LogFile > $Tomcat6LogSaved" 0 \
          "Storing the contents of tomcat6 log file"
    export Tomcat6LogSaved

    return 0
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# rlSatelliteAssertTomcat6LogNotDiffer
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rlSatelliteAssertTomcat6LogNotDiffer(){
    if [ ! -e "$Tomcat6LogSaved" ]; then
        __INTERNAL_LogAndJournalFail "rlSatelliteAssertTomcat6LogNotDiffer cannot assert because log has not been probably saved before"
        return 1
    fi 

    AdditionTmpFile=$( mktemp )

    # Get just the new lines and strip the ">  " prefix
    diff "$Tomcat6LogSaved" "$Tomcat6LogFile" | grep "^> " | cut -c 3- > "$AdditionTmpFile"

    local msg="There should not be any addition to tomcat6 log"
   
    # if addition is not empty
    if [ -s "$AdditionTmpFile" ]; then
        __INTERNAL_LogAndJournalFail "$msg"
        rlLog "`cat $AdditionTmpFile`"
        return 1
    fi

    __INTERNAL_LogAndJournalPass "$msg"
    return 0
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# AUTHORS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
: <<=cut
=pod

=head1 AUTHORS

=over

=item *

Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>

=back

=cut

